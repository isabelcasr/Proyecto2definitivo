library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_sync is
    port (
        -- reloj principal del sistema
        clk     : in  std_logic;
        -- reset general para volver a la dirección 0
        rst     : in  std_logic;
        -- señal que limpia el contador cuando la FSM lo necesita
        clr_cnt : in  std_logic;
        -- señal que incrementa la dirección de memoria
        inc_cnt : in  std_logic;
        -- salida del contador, usada como dirección para ROM y RAM
        addr    : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of contador_sync is

    -- contador interno de 4 bits
    signal cnt : unsigned(3 downto 0) := (others => '0'); -- se usa unsigned para poder sumarle 1 fácilmente

begin

    process(clk, rst)
    begin
        -- si reset está activo, la dirección vuelve a 0000
        if rst = '1' then
            cnt <= (others => '0');

        -- el contador solo cambia en el flanco de subida del reloj
        elsif rising_edge(clk) then
		  
            if clr_cnt = '1' then -- esto asegura que cuando se quiera limpiar no incremente al mismo tiempo
                cnt <= (others => '0');
					 elsif inc_cnt = '1' then  -- cuando inc_cnt está activo, pasa a la siguiente dirección
                cnt <= cnt + 1;

            end if;

        end if;
    end process;
    addr <= std_logic_vector(cnt);-- se convierte cnt de unsigned a std_logic_vector para conectarlo a las memorias
end architecture;