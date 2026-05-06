library ieee;
use ieee.std_logic_1164.all;

entity divisor_reloj is
    generic (
        -- este valor define cada cuánto se genera el pulso lento entre más grande sea, más lento cambia la secuencia
        FIN_CONTEO : integer := 14999999
    );
    port (
        -- reloj principal de la fpga de 50 MHz
        clk_50mhz : in  std_logic;
        -- reset del divisor, vuelve el contador interno a cero
        rst       : in  std_logic;
        -- salida se activa en 1 solo por un ciclo de reloj
        clk_1hz   : out std_logic
    );
end entity;

architecture rtl of divisor_reloj is

    -- contador que va sumando ciclos del reloj de 50 MHz cuando llega a FIN_CONTEO se reinicia
    signal contador : integer range 0 to FIN_CONTEO := 0;
    -- señal interna que genera el pulso lento no es un reloj continuo, solo se activa un instante
    signal tick_reg : std_logic := '0';

begin

    process(clk_50mhz, rst)
    begin
        -- si el reset está activo, se limpia el contador y se apaga el pulso
        if rst = '1' then
            contador <= 0;
            tick_reg <= '0';

        -- todo el conteo se hace con el flanco de subida del reloj principal
        elsif rising_edge(clk_50mhz) then

            -- si ya se llegó al límite, se genera un tick
            if contador = FIN_CONTEO then
                contador <= 0;
                tick_reg <= '1';

            -- si todavía no llega al límite, sigue contando
            else
                contador <= contador + 1;
                tick_reg <= '0';
            end if;

        end if;
    end process;

    -- se conecta la señal interna del pulso a la salida del componente
    clk_1hz <= tick_reg;

end architecture;