-- Proyek Akhir PSD Kelompok A5
-- Vending Machine

--Deklarasi Library
library IEEE;
use IEEE.std_logic_1164.all;

--entity
entity vend_mch is
	port(
		-- Input Vending Machine
		nominal : in std_logic_vector(1 downto 0) := "00"; --Input duit
		sel		: in std_logic_vector(3 downto 0) := "0000"; -- Pilih Produk
		clk		: in std_logic;
		ambil	: in std_logic := '0'; --Mengambil kembalian
		
		--Output Vending Machine
		kembali	: out string(1 to 9) := "Rp  0.000"; --Kembalian
		
		--Food
		permen	: out std_logic := '0';
		chitato	: out std_logic := '0';
		nasgor	: out std_logic := '0';
		sushi	: out std_logic := '0';
		
		--Beverages
		leminerale: out std_logic := '0';
		tehpucuk	: out std_logic := '0';
		matcha	: out std_logic := '0';
		starbucks: out std_logic := '0'
	);
end vend_mch;

architecture arch of vend_mch is
	--States 
	type state_types is (start, rp5, rp10, rp15, rp20, done);
	signal present_state, next_state : state_types := start;
	
	--Sinyal pemilihan produk dan produk yang tersedia sesuai nominal
	signal sel_prod : std_logic_vector(3 downto 0) := "0000";
	signal prod5rb : std_logic := '0';
	signal prod10rb : std_logic := '0';
	signal prod15rb : std_logic := '0';
	signal prod20rb : std_logic := '0';	
	
	
begin
					
	--============Finite State Machine========--
	
	-- Synchronus
	sync_proc: process (clk, next_state, ambil)
	begin
		-- Jika mengambil kembalian maka state kembali ke awal
		if (ambil = '1') then
			present_state <= start;
		-- Memindahkan next state sebagai present state setiap clock
		elsif (rising_edge(clk)) then
			present_state <= next_state;
		end if;
	end process sync_proc;
	
	-- Combinatorial
	comb_proc: process (clk, present_state, nominal)
	begin
	--assign pilihan produk ke signal 
	sel_prod <= sel;
	
		case(present_state) is
			when start =>
				--Memindahkan next state sesuai dengan uang yang dimasukkan
				case(nominal) is
					when "01" 	=> next_state <= rp5;
					when "10" 	=> next_state <= rp10;
					when "11" 	=> next_state <= rp20;
					when others => next_state <= start;
				end case;
				
			-- State ketika dimasukkan 5 ribu
			when rp5 =>
			
				if (sel_prod = "0000") then
				--Jika tidak memilih produk maka membaca input duit lagi
					case (nominal) is
						when "01" 	=> next_state <= rp10;
						when "10" 	=> next_state <= rp15;
						when others => next_state <= rp5;
					end case;
				else
				--Jika dibeli produk 5ribu maka state vending machine selesai
					case(sel_prod) is
						when "0001"|"0101" => next_state <= done;
						when others => next_state <= rp5;
					end case;
				end if;
				
			-- State ketika dimasukkan 10 ribu
			when rp10=>
				--Jika tidak memilih produk maka membaca input duit lagi
				if(sel_prod = "0000") then
					case (nominal) is
						when "01" 	=> next_state <= rp15;
						when "10" 	=> next_state <= rp20;
						when others => next_state <= rp10;
					end case;
				else
				--Membeli produk 5 ribu akan berpindah state, sedangkan 
				--untuk pembelian produk 10 ribu state vend machine selesai
					case (sel_prod) is
						when "0001"|"0101" => next_state <= rp5;
						when "0010"|"0110" => next_state <= done;
						when others => next_state <= rp10;
					end case;
				end if;
				
			-- Kondisi ketika dimasukkan 15 ribu
			when rp15 =>
				--Jika tidak memilih produk maka membaca input duit lagi
				if(sel_prod = "0000") then
					case(nominal) is
						when "01" 	=> next_state <= rp20;
						when others => next_state <= rp15;
					end case;
				else
				--Mendefinisikan kondisi state berdasarkan pembelian produk 
					case(sel_prod) is
						when "0001"|"0101" => next_state <= rp10;
						when "0010"|"0110" => next_state <= rp5; 
						when "0011"|"0111" => next_state <= done;
						when others => next_state <= rp15;
					end case;
				end if;
				
			-- Kondisi ketika dimasukkan 20 ribu
			when rp20 =>
				case(sel_prod) is
					when "0001"|"0101" => next_state <= rp15;
					when "0010"|"0110" => next_state <= rp10;
					when "0011"|"0111" => next_state <= rp5;
					when "0100"|"1000" => next_state <= done;
					when others => next_state <= rp20;
				end case;
				
			when done =>
				next_state <= start;
		
		end case;
	end process comb_proc;
	
	-- Pemberian produk
	cekUang: process(clk, next_state, sel_prod, ambil)
	begin
		if (clk = '1') then
		--Sebagagi signal untuk menyesuaikan produk yang bisa dibeli sesuai
		--dengan duit yang dimasukkan
			case (present_state) is 
				when rp5 =>
					prod5rb <= '1';
					prod10rb <= '0';
					prod15rb <= '0';
					prod20rb <= '0';
				
				when rp10 =>
					prod5rb <= '1';
					prod10rb <= '1';
					prod15rb <= '0';
					prod20rb <= '0';
				
				when rp15 => 
					prod5rb <= '1';
					prod10rb <= '1';
					prod15rb <= '1';
					prod20rb <= '0';
				
				when rp20 =>
					prod5rb <= '1';
					prod10rb <= '1';
					prod15rb <= '1';
					prod20rb <= '1';
					
				when others => 
					prod5rb <= '0';
					prod10rb <= '0';
					prod15rb <= '0';
					prod20rb <= '0';
					
			end case;
		end if;
	end process cekUang;

	--Mengeluarkan produk sesuai yang telah dipilih 
	permen		<= '1' when sel_prod = "0001" AND prod5rb = '1' else '0';
	chitato		<= '1' when sel_prod = "0010" AND prod10rb = '1' else '0';
	nasgor		<= '1' when sel_prod = "0011" AND prod15rb = '1' else '0';
	sushi		<= '1' when sel_prod = "0100" AND prod20rb = '1' else '0';
	leminerale	<= '1' when sel_prod = "0101" AND prod5rb = '1' else '0';
	tehpucuk	<= '1' when sel_prod = "0110" AND prod10rb = '1' else '0';
	matcha		<= '1' when sel_prod = "0111" AND prod15rb = '1' else '0';
	starbucks	<= '1' when sel_prod = "1000" AND prod20rb = '1' else '0';
	
	--Menampilkan kembalian yang akan diberikan vending machine
	kembali		<= 	"Rp  5.000" when present_state = rp5 else
					"Rp 10.000" when present_state = rp10 else
					"Rp 15.000" when present_state = rp15 else
					"Rp 20.000" when present_state = rp20 else
					"Rp  0.000";
					
end arch;		
					
	
