`timescale 1s/1s

module spitest;
reg reset_tb,clock_tb;
wire addrload_tb;
wire dataload_tb;
wire commload_tb;
reg [7:0] addrreg_tb1;
reg [7:0] datareg_tb1;
reg [7:0] addrReg_tb;
reg [7:0] dataReg_tb;
reg commreg_tb;
wire sdiM;
reg sdo;
reg [3:0] count;
reg [3:0] countD;
spi i1 (.reset(reset_tb),.clock(clock_tb),.sdoM(sdo),.sdoS(sdiM),.addrload(addrload_tb),.comload(commload_tb),.dataload(dataload_tb));

initial
begin
$dumpfile("spi.vcd");
$dumpvars(0,spitest);
clock_tb <= 0;
reset_tb <=0;
addrReg_tb <= 63;
dataReg_tb <= 35;
commreg_tb <= 1;
/*addrreg_tb1 = 0;
datareg_tb1 <= 4;*/
count <= 8;
countD <= 8;
end

always #1 clock_tb = ~clock_tb;

always @(negedge clock_tb)
begin

if(addrload_tb==1)
begin
sdo <= addrReg_tb[7];
addrReg_tb <= addrReg_tb << 1;
count <= count - 1;
if(count==0)
begin
addrReg_tb <= addrReg_tb + 100;
count <= 7;
end
end

if(dataload_tb==1)
begin
sdo <= dataReg_tb[7];
dataReg_tb <= dataReg_tb << 1;
countD <= countD - 1;
if(countD==0)
begin
dataReg_tb <= dataReg_tb + 120;
countD <= 8;
end
end

if(commload_tb==1)
begin
sdo <= commreg_tb;
commreg_tb <= ~commreg_tb;
end

end
endmodule
