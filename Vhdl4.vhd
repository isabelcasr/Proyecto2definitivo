library ieee;
use ieee.std_logic_1164.all;

-- este paquete sirve para declarar todos los componentes del proyecto
package microproyecto_pkg is

    -- componente de la memoria ROM
    -- esta memoria tiene datos fijos y solo se usa para lectura
    component rom_sync is
        port (
            clk      : in  std_logic; -- reloj que sincroniza la salida de datos
            -- señal de habilitación de lectura
            -- cuando está en 1 permite entregar el dato de la dirección indicada
            re       : in  std_logic;
            -- dirección que se quiere leer dentro de la ROM en este proyecto se usan direcciones de 0 a 3
            addr     : in  std_logic_vector(3 downto 0);
            -- dato que sale de la ROM según la dirección seleccionada
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    -- componente de la memoria RAM
    -- esta memoria permite guardar y leer datos durante el funcionamiento
    component ram_sincrona is
        port (
            -- reloj principal para sincronizar lectura y escritura
            clk      : in  std_logic;
            -- habilitación de escritura cuando está en 1 guarda data_in en la dirección addr
            we       : in  std_logic;
            -- habilitación de lectura cuando está en 1 permite sacar el dato guardado
            re       : in  std_logic;
            -- dirección de la RAM donde se lee o escribe
            addr     : in  std_logic_vector(3 downto 0);
            -- dato que entra a la RAM, viene normalmente desde la ROM
            data_in  : in  std_logic_vector(7 downto 0);
            -- dato que sale de la RAM después de leer una dirección
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    -- componente que convierte el dato de memoria a display de 7 segmentos
    component decodificador_7seg is
        port (
            -- dato de 8 bits que representa la letra o símbolo a mostrar
            data_in : in  std_logic_vector(7 downto 0);

            -- salida hacia los segmentos del display
            -- cada bit controla un segmento del display
            seg_out : out std_logic_vector(6 downto 0)
        );
    end component;

    -- componente divisor de reloj que se usa para generar un pulso más lento a partir del reloj de 50 MHz
    component divisor_reloj is
        generic (
            -- define la velocidad con la que cambian las letras
            FIN_CONTEO : integer := 2499999  -- valor máximo del conteo interno
        );
        port (
            -- reloj principal de la FPGA
            clk_50mhz : in  std_logic;
            -- reset para reiniciar el conteo interno del divisor
            rst       : in  std_logic;
            -- salida del divisor
            clk_1hz   : out std_logic
        );
    end component;
    -- componente contador de direcciones que se encarga de pasar por las posiciones de memoria
    component contador_sync is
        port (
            -- reloj principal del sistema
            clk     : in  std_logic;
            -- reset general para volver el contador a cero
            rst     : in  std_logic;
            -- señal para limpiar el contador desde la unidad de control
            clr_cnt : in  std_logic;
            -- señal para aumentar la dirección actual
            inc_cnt : in  std_logic;
            -- dirección generada por el contador
            addr    : out std_logic_vector(3 downto 0)
        );
    end component;
    -- esta es la máquina de estados que coordina todo el proceso
    component control_unit is
        port (
            -- reloj principal con el que trabaja la FSM
            clk     : in  std_logic;
            -- reset para regresar la FSM al estado inicial
            rst     : in  std_logic;
            -- pulso lento que marca cuándo avanzar de estado
            tick    : in  std_logic;
            -- señal que viene del botón de start
            start   : in  std_logic;
            -- dirección actual del contador
            -- se usa para saber cuándo ya llegó a la última posición
            addr_in : in  std_logic_vector(3 downto 0);
            -- salida que limpia el contador de direcciones
            clr_cnt : out std_logic;
            -- salida que incrementa el contador
            inc_cnt : out std_logic;
            -- salida que habilita escritura en la RAM
            we_out  : out std_logic;
            -- salida que habilita lectura en ROM y RAM
            re_out  : out std_logic;
            -- salida que indica que el sistema está listo o terminó
            ready   : out std_logic
        );
    end component;

end package;