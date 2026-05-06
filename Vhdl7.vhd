library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        clk     : in  std_logic; -- reloj principal del sistema
        rst     : in  std_logic; -- reset para devolver la maquina al estado inicial
        tick    : in  std_logic; -- pulso lento que indica cuando avanzar al siguiente paso
        start   : in  std_logic; -- boton de inicio del proceso
        addr_in : in  std_logic_vector(3 downto 0); -- direccion actual del contador
        clr_cnt : out std_logic; -- limpia el contador de direcciones
        inc_cnt : out std_logic; -- incrementa la direccion del contador
        we_out  : out std_logic; -- habilita escritura en RAM
        re_out  : out std_logic; -- habilita lectura de ROM/RAM
        ready   : out std_logic  -- indica que el sistema esta listo o termino
    );
end entity;

architecture rtl of control_unit is

    -- estados de la maquina de control
    type state_type is (
        S_IDLE,   -- espera inicial
        S_CLEAR,  -- limpia contador
        S_READ,   -- lee dato de ROM
        S_WRITE,  -- escribe dato en RAM
        S_NEXT,   -- pasa a la siguiente direccion
        S_DONE    -- proceso terminado
    );

    signal state_reg  : state_type := S_IDLE; -- guarda el estado actual
    signal state_next : state_type := S_IDLE; -- calcula el siguiente estado

begin

    -- proceso secuencial que actualiza el estado actual
    process(clk, rst)
    begin
        -- con reset vuelve directamente al estado inicial
        if rst = '1' then
            state_reg <= S_IDLE;

        -- en cada flanco de subida se carga el siguiente estado
        elsif rising_edge(clk) then
            state_reg <= state_next;

        end if;
    end process;

    -- proceso combinacional que decide el siguiente estado
    process(state_reg, start, tick, addr_in)
    begin
        -- por defecto se queda en el mismo estado
        state_next <= state_reg;

        case state_reg is

            when S_IDLE =>
                -- espera a que el usuario presione start
                if start = '1' then
                    state_next <= S_CLEAR;
                else
                    state_next <= S_IDLE;
                end if;

            when S_CLEAR =>
                -- espera un tick para avanzar
                -- durante este estado se limpia la direccion
                if tick = '1' then
                    state_next <= S_READ;
                else
                    state_next <= S_CLEAR;
                end if;

            when S_READ =>
                -- activa la lectura del dato que esta en la ROM
                -- cuando llega el tick pasa a escribirlo en la RAM
                if tick = '1' then
                    state_next <= S_WRITE;
                else
                    state_next <= S_READ;
                end if;

            when S_WRITE =>
                -- escribe en la RAM el dato leido desde la ROM
                -- luego pasa al estado donde se revisa la direccion
                if tick = '1' then
                    state_next <= S_NEXT;
                else
                    state_next <= S_WRITE;
                end if;

            when S_NEXT =>
                -- aqui se revisa si ya se llego a la ultima direccion usada
                if tick = '1' then

                    -- direccion 0011 equivale a 3
                    -- como se usan 4 datos, las direcciones van de 0 a 3
                    if addr_in = "0011" then
                        state_next <= S_DONE;
                    else
                        state_next <= S_READ;
                    end if;

                else
                    state_next <= S_NEXT;
                end if;

            when S_DONE =>
                -- estado final, el sistema queda detenido
                if start = '1' then
                    state_next <= S_CLEAR;
                else
                    state_next <= S_DONE;
                end if;

        end case;
    end process;

    -- proceso combinacional que genera las salidas segun el estado actual
    -- se agrega addr_in porque ahora se usa para decidir si se incrementa o no
    process(state_reg, tick, addr_in)
    begin
        -- valores por defecto para que ninguna señal quede activa sin querer
        clr_cnt <= '0';
        inc_cnt <= '0';
        we_out  <= '0';
        re_out  <= '0';
        ready   <= '0';

        case state_reg is

            when S_IDLE =>
                clr_cnt <= '1'; -- mientras esta quieto, mantiene el contador en cero
                ready   <= '1'; -- ready en 1 indica que el sistema esta listo

            when S_CLEAR =>
                -- limpia el contador antes de empezar a leer la ROM
                clr_cnt <= '1';

            when S_READ =>
                -- habilita lectura para que la ROM entregue el dato de la direccion actual
                re_out <= '1';

            when S_WRITE =>
                -- mantiene lectura activa para conservar el dato de entrada
                re_out <= '1';

                -- la escritura en RAM solo se activa justo cuando llega el tick
                -- asi se guarda una sola vez por cada direccion
                if tick = '1' then
                    we_out <= '1';
                end if;

            when S_NEXT =>
                -- cuando llega el tick se incrementa la direccion
                -- pero solo si todavia no se llego a la ultima direccion
                if tick = '1' then

                    -- si ya esta en 0011 no incrementa mas
                    -- esto evita que pase a 0100 antes de terminar
                    if addr_in /= "0011" then
                        inc_cnt <= '1';
                    end if;

                end if;

            when S_DONE =>
                -- indica que ya termino de copiar los datos
                ready <= '1';

        end case;
    end process;

end architecture;