library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- aquí no hay entradas ni salidas físicas porque todo se simula internamente
entity top_system_tb is
end entity;

architecture sim of top_system_tb is
    component top_system is
        generic (
            LIMIT_VAL : integer := 14999999
        );
        port (
            -- reloj principal del sistema
            CLOCK_50 : in  std_logic;
            -- botones simulados
            -- BUTTON(0) es reset y BUTTON(1) es start
            BUTTON   : in  std_logic_vector(1 downto 0);
            -- switch para seleccionar qué RAM se quiere mostrar
            SW       : in  std_logic_vector(0 downto 0);
            -- salida al display de 7 segmentos
            HEX0     : out std_logic_vector(6 downto 0);
            -- LED de estado del sistema
            LEDG     : out std_logic_vector(0 downto 0)
        );
    end component;

    -- señal simulada para el reloj de 50 MHz
    signal CLOCK_50_tb : std_logic := '0';

    -- botones simulados
    signal BUTTON_tb : std_logic_vector(1 downto 0) := "11"; -- se inicializan en "11" porque los botones reales son activos en bajo

    -- switch simulado
    signal SW_tb : std_logic_vector(0 downto 0) := "0"; -- inicia en 0 para mostrar la RAM A

    -- señal donde se observa la salida del display
    signal HEX0_tb : std_logic_vector(6 downto 0);

    -- señal donde se observa el LED
    signal LEDG_tb : std_logic_vector(0 downto 0);

    -- periodo del reloj de 50 MHz
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz equivale a un periodo de 20 ns

begin

    -- se usa LIMIT_VAL pequeño para que el tick salga rápido en simulación
    DUT: top_system
        generic map (
            LIMIT_VAL => 5
        )
        port map (
            CLOCK_50 => CLOCK_50_tb,
            BUTTON   => BUTTON_tb,
            SW       => SW_tb,
            HEX0     => HEX0_tb,
            LEDG     => LEDG_tb
        );

    -- proceso que genera el reloj de prueba que alterna entre 0 y 1 cada 10 ns para formar un periodo total de 20 ns
    clk_process: process
    begin
        CLOCK_50_tb <= '0';
        wait for CLK_PERIOD / 2;

        CLOCK_50_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- proceso de estímulos donde se simula presionar reset, start y cambiar el switch
    stim_process: process
    begin

        -- estado inicial del sistema ningún botón está presionado y se muestra la RAM A
        BUTTON_tb <= "11";
        SW_tb <= "0";
        wait for 100 ns;

        -- se presiona reset como el botón es activo en bajo, se pone BUTTON(0) en 0
        BUTTON_tb(0) <= '0';
        wait for 100 ns;

        -- se suelta reset, vuelve a 1 porque ya no está presionado
        BUTTON_tb(0) <= '1';
        wait for 100 ns;

        -- se presiona start para iniciar la copia de ROM a RAM
        BUTTON_tb(1) <= '0'; -- BUTTON(1) en 0 significa botón presionado
        wait for 100 ns;

        -- se suelta start
        BUTTON_tb(1) <= '1';

        -- se espera a que el sistema haga la secuencia completa
        wait for 3000 ns;

        -- se cambia el switch a 1 para mostrar la RAM B
        SW_tb(0) <= '1';
        wait for 1000 ns;

        -- se vuelve el switch a 0 para mostrar la RAM A
        SW_tb(0) <= '0';
        wait for 1000 ns;

        -- se prueba reset después de terminar el proceso
        BUTTON_tb(0) <= '0';
        wait for 100 ns;

        -- se suelta reset otra vez
        BUTTON_tb(0) <= '1';
        wait for 1000 ns;

        -- se detiene la simulación dejando el proceso en espera
        wait;

    end process;

end architecture;