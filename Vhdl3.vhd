library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_sincrona is
    port (
        
        clk      : in  std_logic;-- Esta es la señal del reloj
        we       : in  std_logic; -- Esta señal permite escribir en la memoria
        re       : in  std_logic; -- Esta señal permite leer de la memoria
        addr     : in  std_logic_vector(3 downto 0);-- Esta es la dirección que se va a usar en la memoria
        data_in  : in  std_logic_vector(7 downto 0); -- Este es el dato que entra para guardarse
        data_out : out std_logic_vector(7 downto 0) -- Este es el dato que sale de la memoria

    );

end entity;

architecture behavioral of ram_sincrona is

    type ram_type is array (0 to 15) of std_logic_vector(7 downto 0);-- Creo un tipo de memoria con 16 espacios y cada espacio tiene 8 bits

    signal mem : ram_type := (others => (others => '0'));-- Creo la memoria y la inicio toda en cero

    signal reg_addr : std_logic_vector(3 downto 0);-- Creo una señal para guardar la dirección que se va a leer

begin

    process(clk)-- Este proceso depende del reloj

    begin

        if clk'event and clk = '1' then -- Esto revisa si llegó un flanco de subida del reloj

            if we = '1' then-- Si we vale 1 entonces se puede escribir

                mem(to_integer(unsigned(addr))) <= data_in;-- Guardo data_in en la posición indicada por addr

            end if;
            if re = '1' then
            -- Si re vale 1 entonces se puede leer

                reg_addr <= addr;
                -- Guardo la dirección que quiero leer

            end if;

        end if;
    end process;

    data_out <= mem(to_integer(unsigned(reg_addr)));-- La salida muestra el dato guardado en la dirección reg_addr

end architecture;