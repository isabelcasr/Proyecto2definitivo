library ieee;
use ieee.std_logic_1164.all;

entity decodificador_7seg is
    port (
        data_in : in  std_logic_vector(7 downto 0); -- Dato proveniente de la RAM
        seg_out : out std_logic_vector(6 downto 0)  -- Salida a los segmentos (orden: g f e d c b a)
    );
end entity;

architecture rtl of decodificador_7seg is
begin
    process(data_in)
    begin
        -- Nota: Los displays en FPGAs encienden con '0'
        case data_in is
            when x"00" => seg_out <= "0001000"; -- Dibuja la letra A
            when x"01" => seg_out <= "0000011"; -- Dibuja la letra b
            when x"02" => seg_out <= "1000110"; -- Dibuja la letra C
            when x"03" => seg_out <= "0100001"; -- Dibuja la letra d
            when others => seg_out <= "1111111"; -- Apaga todo
        end case;
    end process;
end architecture;