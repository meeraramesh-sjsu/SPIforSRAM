module spi(sdoS,clock,reset,sdoM,addrload,dataload,comload);

input reset,clock;
output addrload;
output dataload;
output comload;

input sdoM;

output sdoS;

reg ssbar,lcb,dataload,comload,addrload,shift,lab,ldb,de,ae,ce,commandbuf; /*made changes here*/
reg [5:0] a;
reg [5:0] temp;
reg [7:0] addrbuf;
reg [7:0] databuf;
reg [2:0] addrcount;
reg [2:0] datacount;
reg [2:0] outputcount;
reg [7:0] outputreg;
reg [7:0] sram [255:0];

reg [7:0] addr;
reg comm;
reg [7:0] din;
reg [7:0] dout;
reg regload;
reg regdataload;
reg resetext;
reg sdoS;
reg[7:0] i;

initial
begin
a <= -1;
temp <= 0;
de <= 0;
ae <= 0;
ce <= 0;
addrcount <= 7;
datacount <= 7;
outputcount <= 7;
resetext <= 0;
sram[31] <= 31;
sram[50] <= 50;
end

always @(negedge clock)
begin
a=a+1;
if(reset==0 && resetext==0)
begin
ssbar <= (~a[5]&a[4]&~a[3]&~a[2]&a[1]&~a[0]) | (~a[5]&a[4]&a[3]&a[2]&~a[1]&~a[0]) | (~a[5]&a[4]&a[3]&a[2]&~a[1]&a[0]) | (a[5]&~a[4]&a[3]&a[2]&a[1]&a[0]);
lcb <= (~a[5]&~a[4]&a[3]&~a[2]&~a[1]&a[0]) | (~a[5]&a[4]&a[3]&~a[2]&a[1]&a[0]) | (a[5]&~a[4]&~a[3]&a[2]&a[1]&~a[0]);
dataload <= (~a[5]&~a[4]&~a[3]&~a[2]&~a[1]&~a[0]) | (~a[5]&a[4]&~a[3]&~a[2]&a[1]&~a[0]);
ae <=(~temp[5]&temp[4]&~temp[3]&~temp[2]&temp[1]&~temp[0]) |(temp[5]&~temp[4]&temp[3]&temp[2]&temp[1]&temp[0]) | (~temp[5]&temp[4]&temp[3]&temp[2]&~temp[1]&~temp[0]);
ce <=(~temp[5]&temp[4]&~temp[3]&~temp[2]&temp[1]&~temp[0]) |(temp[5]&~temp[4]&temp[3]&temp[2]&temp[1]&temp[0]) | (~temp[5]&temp[4]&temp[3]&temp[2]&~temp[1]&~temp[0]);
de <=(~temp[5]&temp[4]&~temp[3]&~temp[2]&temp[1]&~temp[0]) | (temp[5]&~temp[4]&temp[3]&temp[2]&temp[1]&temp[0]);

/*Remove load and change ae,de*/

/*addrload <= (~a[5]&~a[4]&~a[3]&~a[2]&~a[1]&~a[0]) | (~a[5]&~a[4]&a[3]&~a[2]&~a[1]&a[0]) | (~a[5]&a[4]&a[3]&~a[2]&a[1]&a[0]);*/
/*comload <= (~a[5]&~a[4]&~a[3]&~a[2]&~a[1]&~a[0]) |  (~a[5]&~a[4]&a[3]&~a[2]&a[1]&~a[0]) | (~a[5]&a[4]&a[3]&a[2]&~a[1]&~a[0]);*/
resetext <= (a[5] & a[4] & ~a[3] & ~a[2] & a[1] & ~a[0]);

if((a>=1 && a<=8) || (a>=19 && a<=26) || (a>=30 && a<=37)) lab <= 1;
else lab<=0;
if((a>=0 && a<=7) || (a>=18 && a<=25) || (a>=29 && a<=36)) addrload <= 1;
else addrload<=0;

comload <= (~a[5]&~a[4]&a[3]&~a[2]&~a[1]&~a[0]) || (~a[5]&a[4]&a[3]&~a[2]&a[1]&~a[0]) | (a[5]&~a[4]&~a[3]&a[2]&~a[1]&a[0]);  /*8,26,37 */

if((a>=10 && a<=17) || (a>=39 && a<=46)) ldb <= 1;
else ldb <= 0;

if((a>=9 && a<=16) || (a>=38 && a<=45)) dataload <= 1;
else dataload <= 0;

if(a>=30 && a<=37) shift <=1;
else shift<=0;

if(lab==1)
begin
addrbuf[addrcount] <= sdoM;
addrcount <= addrcount - 1;
end

if(ldb==1)
begin
databuf[datacount] <= sdoM;
datacount <= datacount - 1;
end

if(lcb==1)
begin
commandbuf <= sdoM;
end

if(shift==1)
begin
sdoS <= dout[7];
dout <= dout << 1;
end
end
end

always @(posedge clock)
begin
temp=temp+1;
if(reset==0 && resetext==0)
begin
/* Reduced expression for counter-decoder scheme*/
if(ssbar==1)
begin

if(ae==1 && ce==1)
begin
/*$display("commandbuf %d de %d addrbuf %d sram %d ae %d ce %d",commandbuf,de,addrbuf,sram[addrbuf],ae,ce);*/
if(commandbuf==1 && de==1)
begin
sram[addrbuf] <= databuf;
/*$display("While writing %d",sram[addrbuf]);*/
end
else if(commandbuf==0)
begin
/*$display("While reading %d",sram[addrbuf]);*/
dout<=sram[addrbuf];
end
end
end

end
end
endmodule