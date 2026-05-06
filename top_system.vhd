library ieee;
use ieee.std_logic_1164.all;
use work.microproyecto_pkg.all;

entity top_system is
    generic (
        -- controla la velocidad general del cambio de letras
        LIMIT_VAL : integer := 14999999
    );
    port (
        -- reloj físico de la fpga
        CLOCK_50 : in  std_logic;

        -- BUTTON(0) se usa como reset
        -- BUTTON(1) se usa como start
        BUTTON   : in  std_logic_vector(1 downto 0);

        -- switch para escoger qué RAM mostrar
        SW       : in  std_logic_vector(0 downto 0);

        -- display de 7 segmentos
        HEX0     : out std_logic_vector(6 downto 0);

        -- LED indicador de listo o terminado
        LEDG     : out std_logic_vector(0 downto 0)
    );
end entity;

architecture structural of top_system is

    -- pulso lento generado por el divisor
    -- este pulso controla cuándo avanza la máquina
    signal tick_slow : std_logic;

    signal rst_int   : std_logic; -- señales internas para reset y start
    signal start_int : std_logic;
	 
    -- esta dirección cambia con el contador
    signal s_addr : std_logic_vector(3 downto 0);-- dirección común para ROM y RAM

    -- señales de control generadas por la FSM
    signal s_clr   : std_logic;
    signal s_inc   : std_logic;
    signal s_we    : std_logic;
    signal s_re    : std_logic;
    signal s_ready : std_logic;

    -- salida de datos de la ROM A y RAM A
    signal data_rom_a : std_logic_vector(7 downto 0);
    signal data_ram_a : std_logic_vector(7 downto 0);

    -- salida de datos de la ROM B y RAM B
    signal data_rom_b : std_logic_vector(7 downto 0);
    signal data_ram_b : std_logic_vector(7 downto 0);

    -- dato seleccionado que finalmente se muestra en el display
    signal dato_a_mostrar : std_logic_vector(7 downto 0);

begin

    -- los botones de la FPGA entregan 0 cuando se presionan
    rst_int   <= not BUTTON(0);
    start_int <= not BUTTON(1);

    -- este bloque genera un tick lento a partir del reloj de 50 MHz
    -- no se usa como reloj principal, solo como señal de avance
    U_DIV: divisor_reloj
        generic map (
            FIN_CONTEO => LIMIT_VAL
        )
        port map (
            clk_50mhz => CLOCK_50,
            rst       => rst_int,
            clk_1hz   => tick_slow
        );

    -- máquina de estados que controla lectura, escritura e incremento
    U_CTRL: control_unit
        port map (
            clk     => CLOCK_50,-- usa CLOCK_50 para responder rápido al reset y al start
            rst     => rst_int,
            tick    => tick_slow,
            start   => start_int,
            addr_in => s_addr,
            clr_cnt => s_clr,
            inc_cnt => s_inc,
            we_out  => s_we,
            re_out  => s_re,
            ready   => s_ready
        );

    -- contador que genera las direcciones de memoria empieza en 0 y llega hasta 3
    U_CNT: contador_sync
        port map (
            clk     => CLOCK_50,
            rst     => rst_int,
            clr_cnt => s_clr,
            inc_cnt => s_inc,
            addr    => s_addr
        );
-- se usan dos bancos de memoria para representar dos conjuntos de datos independientes
-- ROM A alimenta RAM A y ROM B alimenta RAM B
-- la idea fue hacerlo un poco diferente y mas interesante que usar una sola ROM y una sola RAM

-- con esta estructura se puede simular una seleccion entre bancos de memoria y 
--tambien deja abierta la posibilidad de ampliar el proyecto mas adelante por ejemplo, se podria adaptar para trabajar con datos externos desde un microcontrolador o para cargar diferentes secuencias de datos
-- el switch SW(0) permite seleccionar cual RAM se quiere visualizar en el display por lo que si ambas ROM tienen los mismos datos, el diseño funciona pero es un poco redundante

    -- ROM A contiene los datos fijos que se quieren copiar
    -- entrega el dato correspondiente según s_addr
    ROM_A: rom_sync
        port map (
            clk      => CLOCK_50,
            re       => s_re,
            addr     => s_addr,
            data_out => data_rom_a
        );

    -- RAM A recibe y guarda el dato que viene de ROM A
    -- escribe cuando s_we está activo
    RAM_A: ram_sincrona
        port map (
            clk      => CLOCK_50,
            we       => s_we,
            re       => s_re,
            addr     => s_addr,
            data_in  => data_rom_a,
            data_out => data_ram_a
        );

    -- ROM b funciona igual que ROM a pero como segunda memoria de origen
    ROM_B: rom_sync
        port map (
            clk      => CLOCK_50,
            re       => s_re,
            addr     => s_addr,
            data_out => data_rom_b
        );

    -- RAM B guarda los datos que vienen desde ROM B
    RAM_B: ram_sincrona
        port map (
            clk      => CLOCK_50,
            we       => s_we,
            re       => s_re,
            addr     => s_addr,
            data_in  => data_rom_b,
            data_out => data_ram_b
        );

    -- lógica para decidir qué dato se muestra en el display
    dato_a_mostrar <= x"00"      when rst_int = '1' else -- si reset está activo, se fuerza x"00", que corresponde a A
                      x"00"      when s_ready = '1' else  -- si el sistema terminó, también se muestra A
                      data_rom_a when s_re = '1' else -- si está leyendo, se muestra directamente el dato de la ROM A
                      data_ram_a when SW(0) = '0' else -- si no, el switch decide si se muestra RAM A o RAM B
                      data_ram_b;

    -- convierte el dato hexadecimal en la figura del display de 7 segmentos
    DECODER: decodificador_7seg
        port map (
            data_in => dato_a_mostrar,
            seg_out => HEX0
        );

    -- el LED se prende cuando el sistema está listo o cuando ya terminó
    -- se apaga mientras está haciendo la copia de ROM a RAM
    LEDG(0) <= s_ready;

end architecture;