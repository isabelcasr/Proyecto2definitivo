library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rom_sync is

    port (
        clk      : in  std_logic;
        -- Entrada de reloj del sistema
        -- La ROM solo actualizará su salida en un flanco del reloj

        re       : in  std_logic;
        -- Entrada de habilitación de lectura.
        -- Si re = 1 la ROM lee la dirección indicada
        -- Si re = 0 la salida mantiene el último dato leído

        addr     : in  std_logic_vector(3 downto 0);
        -- Entrada de dirección de 4 bits y como tiene 4 bits, puede representar 16 direcciones

        data_out : out std_logic_vector(7 downto 0)
        -- Salida de datos de 8 bits, por aquí sale el valor almacenado en la ROM

    );
end entity;

architecture behavioral of rom_sync is
-- Aquí se describe el comportamiento interno de la ROM

    type rom_type is array (0 to 15) of std_logic_vector(7 downto 0);
    -- Define un nuevo tipo llamado rom_type el cual ss un arreglo de 16 posiciones, desde la 0 hasta la 15 y cada posición guarda un dato de 8 bits

    constant mem : rom_type := (
    -- Declara una constante llamada mem usando el tipo rom_type, esta constante representa el contenido fijo de la ROM
    -- Al ser constante, no se modifica durante la ejecución

        0 => x"00", -- En la dirección 0 se guarda el valor hexadecimal 00

        1 => x"01", -- En la dirección 1 se guarda el valor hexadecimal 01

        2 => x"02", -- En la dirección 2 se guarda el valor hexadecimal 02

        3 => x"03",-- En la dirección 3 se guarda el valor hexadecimal 03

        others => x"FF" -- Todas las demás direcciones de la 4 a la 15 guardan FF que En binario equivale a 11111111.
        -- Se usa como valor por defecto para las posiciones que no están especificadas

    );

    signal reg_data : std_logic_vector(7 downto 0);
    -- Declara una señal interna de 8 bits llamada reg_data que funciona como un registro donde se guarda el dato leído de la ROM
    -- Luego se conecta a la salida data_out

begin

    process(clk)
    -- Declara un proceso sensible al reloj clk

    begin

        if clk'event and clk = '1' then
        -- Detecta un flanco de subida del reloj, clk'event significa que clk cambió de valor.
        -- Y también se puede escribir como: if rising_edge(clk) then

            if re = '1' then
            -- Verifica si la señal de lectura está habilitada
            -- Solo cuando re vale '1' se lee la memoria

                reg_data <= mem(to_integer(unsigned(addr)));
                -- Convierte addr de std_logic_vector a unsigned, luego convierte ese unsigned a integer
                -- Ese entero se usa como índice para acceder a mem y el dato leído de mem se guarda en reg_data

            end if;
        end if;

    end process;

    data_out <= reg_data;
    -- Asigna continuamente el valor de reg_data a la salida data_out.

end architecture;