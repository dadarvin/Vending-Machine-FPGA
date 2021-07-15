-- Proyek Akhir PSD kelompok A5
-- Vending Machine

--Library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Entity
entity vendMch_tb is
end entity;

--Architecture
architecture vend_arch_tb of vendMch_tb is
	component vend_mch is
	port(
		-- Input Vending Machine
		nominal : in std_logic_vector(1 downto 0) := "00";
		sel		: in std_logic_vector(3 downto 0) := "0000";
		clk		: in std_logic;
		ambil	: in std_logic := '0';
		
		--Output Vending Machine
		kembali	: out string(1 to 9) := "Rp  0.000";
		
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
	end component;
	
	--Mendefinisikan signal untuk melakukan mapping sebagai testbench
	signal nominal 	: std_logic_vector (1 downto 0) := "00";
	signal sel		: std_logic_vector (3 downto 0) := "0000";
	signal clk		: std_logic;
	signal kembali	: string (1 to 9) := "Rp  0.000";
	signal ambil, permen, chitato, nasgor, sushi	: std_logic := '0';
	signal leminerale, tehpucuk, matcha, starbucks : std_logic := '0';
	
	--Mendefinisikan banyak clock, looping, dan periodenya
	constant T		: time := 20ns;
	constant max_clk: integer := 9;
	signal i 		: integer := 0;
	
	begin
		--Melakukan mapping pada Unit under test secara implisit
		UUT: vend_mch port map (nominal, sel, clk, ambil, kembali, permen, chitato, nasgor, sushi, leminerale, tehpucuk, matcha, starbucks);
		
		tb:process
			type duit is array (0 to 9) of std_logic_vector (1 downto 0);
			type pil_produk is array (0 to 9) of std_logic_vector (3 downto 0);
			type exchange is array (0 to 9) of std_logic;
			type kembalian is array (0 to 9) of string (1 to 9);
			
			--Mendeklarasikan nilai untuk melakukan testbench
			constant stream_duit : duit := (0=> "10", 1=>"00",2=>"01", 3=>"00", 4=>"01",5=>"00", 6=>"11", 7=>"00", 8=>"00", 9=>"00");
			constant stream_produk : pil_produk := (0=> "0001", 1=>"0000",2=>"0110", 3=>"0000",4=>"0111", 5=>"0000", 6=>"0011", 7=>"0000", 8=>"0000", 9=>"0000");
			constant ambil_duit: exchange := (0=> '0', 1=>'0',2=>'0', 3=>'0', 4=>'0',5=>'0', 6=>'0', 7=>'0', 8=>'1', 9=>'0');
			constant test_kembali : kembalian := (0=> "Rp  0.000", 1=>"Rp 10.000", 2=>"Rp  5.000", 3=>"Rp 10.000", 4=>"Rp  0.000", 5=>"Rp  0.000", 6=> "Rp  0.000", 7=>"Rp 20.000", 8=>"Rp  5.000", 9=>"Rp  0.000");
			
			begin
			--Melakukan transisi clock
			clk <= '0';
			
			wait for T/2;
			clk <='1';
			wait for T/2;
			
			--Memasukkan nilai testbench sesuai dengan index loop kepada input vending machine
			if(i < max_clk) then i <= i+1;
				ambil <= ambil_duit(i);
				nominal <= stream_duit(i);
				sel <= stream_produk(i);
				else wait;
			end if;
			--Melakukan assert untuk mengecek kesesuaian output vending machine
			assert (kembali = test_kembali(i)) 
			report "Hasil testbench vending machine fail pada loop ke-" & integer'image(i) severity error;
		
		end process;
	
end architecture;