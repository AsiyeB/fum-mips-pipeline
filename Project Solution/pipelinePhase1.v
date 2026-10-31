 module ALU(input [31:0] data1,data2,input [3:0] aluoperation,
output reg [31:0] result,output reg zero,lt,gt);


 always@(aluoperation,data1,data2)
 
  begin
    case (aluoperation)
     
 	   4'b0000 : result = data1 & data2; 
 
      4'b0001 : result = data1 | data2; 
 
      4'b0010 : result = data1 + data2; 
  
 	   4'b0110 : result = data1 - data2; 
    
 	   4'b0111 :  // setOnLessThan
   
 begin 
         
 if (data1<data2)result=1;
  
 
 else result=0;
    
 end
     
 default : result = data1 + data2; // ADD
 
 endcase
    
  
 if(data1>data2)
      begin
 
 gt = 1'b1;
       lt = 1'b0;
 
end
 else if(data1<data2)
      begin
 
 gt = 1'b0;
       lt = 1'b1;  
     
 end
 
      
    if (result==32'd0) zero=1'b1;
 
 else zero=1'b0;
 
     
  end

 

endmodule



	
 
 
 
 
 
 
 
 module aluControl(input [5:0]fun,input [1:0]aluOp,input [5:0]opcode,output reg[3:0] opration1);
reg [3:0]opration;
     
    //opration=opration1;
  always@(*)begin
     opration1[0] = (fun[0]|fun[3])&aluOp[1];
     opration1[1] = ~(fun[2]&aluOp[1]);
     opration1[2] = (aluOp[1]&fun[1])|aluOp[0];
     opration1[3] =1'b0;
     if(aluOp==2'b11)
       begin
         
         case(opcode)
             6'b001000://addi
              opration1=4'b0010;
             6'b001100://andi
              opration1=4'b0000;
             6'b001101://ori
              opration1=4'b0001;
             6'b001010://slti
              opration1=4'b0111;
           endcase
            
           end
           
           end
endmodule

module ControlAll(input [5:0] opcode,output reg [1:0] ALUOp,
output reg jump,Branch, MemRead,MemtoReg, MemWrite,ALUSrc, RegWrite,RegDst);

always @(*) begin
 
//initial begin
    case(opcode)
      6'b000000: begin//Rtype
      jump = 1'b0;
      RegDst =1'b1;
      ALUSrc = 1'b0;
      MemtoReg = 1'b0;
      RegWrite = 1'b1;
      MemRead = 1'b0;
      MemWrite = 1'b0;
      Branch = 1'b0;
      ALUOp = 2'b10;
     end
6'b100011: begin//lw
jump = 1'b0;
RegDst = 1'b0;
ALUSrc = 1'b1;
MemtoReg = 1'b1;
RegWrite = 1'b1;
MemRead = 1'b1;
MemWrite = 1'b0;
Branch = 1'b0;
ALUOp = 2'b00;
end
6'b001000: begin//addi
jump = 1'b0;
RegDst = 1'b0;
ALUSrc = 1'b1;
MemtoReg = 1'b0;
RegWrite = 1'b1;
MemRead = 1'b0;
MemWrite = 1'b0;
Branch = 1'b0;
ALUOp = 2'b11;
end
6'b001100: begin//andi
jump = 1'b0;
RegDst = 1'b0;
ALUSrc = 1'b1;
MemtoReg = 1'b0;
RegWrite = 1'b1;
MemRead = 1'b0;
MemWrite = 1'b0;
Branch = 1'b0;
ALUOp = 2'b11;
end
6'b001010: begin//slti
jump = 1'b0;
RegDst = 1'b0;
ALUSrc = 1'b1;
MemtoReg = 1'b0;
RegWrite = 1'b1;
MemRead = 1'b0;
MemWrite = 1'b0;
Branch = 1'b0;
ALUOp = 2'b11;
end
6'b001101: begin//ori
jump = 1'b0;
RegDst = 1'b0;
ALUSrc = 1'b1;
MemtoReg = 1'b0;
RegWrite = 1'b1;
MemRead = 1'b0;
MemWrite = 1'b0;
Branch = 1'b0;
ALUOp = 2'b11;
end

6'b101011: begin//sw
jump = 1'b0;
RegDst = 1'b0;
ALUSrc = 1'b1;
MemtoReg = 1'b0;
RegWrite = 1'b0;
MemRead = 1'b0;
MemWrite = 1'b1;
Branch = 1'b0;
ALUOp = 2'b00;
end
6'b000100: begin //beq 
jump = 1'b0;
RegDst = 1'b0;
ALUSrc = 1'b0;
MemtoReg = 1'b0;
RegWrite = 1'b0;
MemRead = 1'b0;
MemWrite = 1'b0;
Branch = 1'b1;
ALUOp = 2'b01;
end
6'b000010: begin //jump
jump = 1'b1;
RegDst = 1'b0;
ALUSrc = 1'b0;
MemtoReg = 1'b0;
RegWrite = 1'b0;
MemRead = 1'b0;
MemWrite = 1'b0;
Branch = 1'b0;
ALUOp = 2'b00;
end
default: 
begin 
jump = 1'b0;
RegDst = 1'b0;
ALUSrc = 1'b0;
MemtoReg = 1'b0;
RegWrite = 1'b0;
MemRead = 1'b0;
MemWrite = 1'b0;
Branch = 1'b0;
ALUOp = 2'b11;
end
endcase
end
endmodule


//memory unit
module DMemBank(input memread, input memwrite, input [7:0] address, input [31:0] writedata, output reg [31:0] readdata);
 
  reg [31:0] mem_array [63:0];
  
  integer i;
  initial 
  begin
    //mem_array[0]=0;
      for (i=0; i<64; i=i+1)   
     mem_array[i]=i;
  end
 
  always@(memread, memwrite, address, mem_array[address], writedata)
  begin
    if(memread)begin
      readdata=mem_array[address];
    end

    if(memwrite)
    begin
      mem_array[address]= writedata;
    end

  end

endmodule



//memory unit
module IMemBank(input memread, input [7:0] address, output reg [31:0] readdata);
 
  reg [31:0] mem_array [63:0];
  
  integer i;
  initial begin
   /* mem_array[0]<=32'b10001100000000010000000000000001;//lw $1,$0,1
    mem_array[1]<=32'b10001100000000100000000000000010;//lw $2,$0,2
    mem_array[2]<=32'b00000000010000010001000000100010;//sub $2,$2,$1
    mem_array[3]<=32'b00000000010000100001100000100000;//add $3,$2,$2
    mem_array[4]<=32'b00010000001000100000000000000001;//beq  $1,$2
    mem_array[5]<=32'b10101100000000100000000000000100;//sw $2,$0,100
    mem_array[6]<=32'b00001000000000000000000000001000;//jump 8
    mem_array[7]<=32'b00000000010000010010000000100101;//or
    mem_array[8]<=32'b00000000010000110011000000100100;//and $6,$2,$3
    mem_array[9]<=32'b00000000000000010011100000101010;//slt $7,$0,$1
    mem_array[10]<=32'b00100000011000110000000000000111;//addi $3,$3,3
    mem_array[11]<=32'b00110000110001100000000000000011;//andi $6,$6,3
    mem_array[12]<=32'b00110100111001110000000000010011;//ori  $7,$7,19
    mem_array[13]<=32'b00101000010000100000000000000001;//slti $2,$2,1	   */
	
	
    
  /* for (i=14; i<64; i=i+1)   
     mem_array[i]=i*10;*/
	 mem_array[1]<=32'b00000000010000100001100000100000;//add $3,$2,$2
	 
	 mem_array[2]<=32'b10001100000000010000000000000001;//lw $1,$0,1
	 	
	 mem_array[3]<=32'b00100000100001000000000000000111;//addi $4,$4,7	 
	 //mem_array[4]<=32'b10101100000000100000000000000100;//sw $2,$0,4
  end
 
  always@(memread, address, mem_array[address])
  begin
    if(memread)begin
      readdata=mem_array[address];
    end
  end

endmodule

 
/*module Multiplexer(input [31:0]in1 ,in2,input select,output [31:0] out)
  initial begin
    assign out=32'b0;
    
    if (select==0)out<=in1;
    else out<=in2;
    end 
  endmodule;*/
module Mux1(inst20_16, inst15_11, RegDst, WriteReg);
input [20:16] inst20_16;
input [15:11] inst15_11;
input RegDst;
output reg [4:0] WriteReg;
always @ (RegDst, inst20_16, inst15_11) begin
case(RegDst)
0 : WriteReg <= inst20_16;
1 : WriteReg <= inst15_11;
endcase
end
endmodule

module Mux2 (ALUSrc,ReadData2,Extend32, ALU_B);
input ALUSrc;
input [31:0] ReadData2,Extend32;
output reg [31:0] ALU_B;
always @(ALUSrc, ReadData2, Extend32) begin
case (ALUSrc)
0: ALU_B <= ReadData2 ;
1: ALU_B <= Extend32;
endcase
end
/*output [31:0] out;
input [31:0]  A0, A1;
input select;
assign out = (select == 1'b0) ? A0 : A1;*/
endmodule

module Mux3 (ReadData, ALUOut, MemtoReg, WriteData_Reg);
input [31:0] ReadData, ALUOut;
input MemtoReg;
output reg [31:0] WriteData_Reg;
always @(*) begin
case (MemtoReg)
0: WriteData_Reg <= ALUOut ;
1: WriteData_Reg <= ReadData;
endcase
end
endmodule
module Mux4 (PCout, Add_ALUOut, AndGateOut, PCin);
input [7:0] PCout, Add_ALUOut;
input AndGateOut;
output reg [7:0] PCin;
initial begin
PCin <= 0;
end
always @(*) begin
case (AndGateOut)
0: PCin <= PCout ;
1: PCin <= Add_ALUOut;
endcase
end
endmodule
module ShiftLeft2 (ShiftIn, ShiftOut);
input [31:0] ShiftIn;
output reg [31:0] ShiftOut;
always @(ShiftIn) begin
ShiftOut = ShiftIn << 2;
end
endmodule
module SignExtend (inst15_0, Extend32);
input [15:0] inst15_0;
output reg [31:0] Extend32;
always @(inst15_0) begin
Extend32[31:0] <= inst15_0[15:0];
end
endmodule  







module RegFile (clk, readreg1, readreg2, writereg, writedata, RegWrite, readdata1, readdata2);
  input [4:0] readreg1, readreg2, writereg;
  input [31:0] writedata;
  input clk, RegWrite;
  output [31:0] readdata1, readdata2;

  reg [31:0] regfile [31:0];

  always @(posedge clk)
  begin
	  regfile[0]=0;
	  regfile[1]=1;
	  regfile[2]=2;
	  regfile[3]=3;
	  regfile[4]=4;
	  regfile[5]=5;
	  
		  	if (RegWrite) 
	 				regfile[writereg] <= writedata;
  end

  assign readdata1 = regfile[readreg1];
  assign readdata2 = regfile[readreg2];
endmodule





`timescale 1 ns/100 ps
module singleCycle(input reset,input clock,
output reg [7:0]pc,output [31:0]aluResult,output [31:0]readdata1,
output [31:0] aluIn2,writedata,output [7:0] resultmultiplexer,output [31:0] instruction,output jump,branch,memRead,memToreg,memWrite,aluSrc,regWrite,regDst);
 // wire [7:0] pc;
  //wire [31:0]instruction;
  //wire jump,branch,memRead,memToreg,memWrite,aluSrc,regWrite,regDst;
  wire [1:0]aluOp;
  wire [31:0]writeReg;//readdata1,writedata, readdata2;
  wire [31:0] aluIn1,readdata2;
  wire [3:0] opration;
  wire  zero,lt,gt;
  wire [31:0] readdataMem;
  //wire [7:0] resultmultiplexer;
  wire [7:0] pc_next;
  reg  [7:0] pc1;
  wire [31:0]  Extend1;
  always @(posedge clock or posedge reset)  
 begin   
      if(reset==0)   
           pc <= 8'b0;  
      else  
           pc <=pc_next;  
                   
 end

  //assign pc1 = pc_current + 8'b1; 
   IMemBank im(1,pc,instruction);
   
   ControlAll c(instruction[31:26],aluOp,jump,branch,memRead,
   memToreg,memWrite,aluSrc,regWrite,regDst);
   
   Mux1 m(instruction[20:16],instruction[15:11],regDst,writeReg);
   
   RegFile rg(clock,instruction[25:21], instruction[20:16], 
   writeReg, writedata, regWrite, readdata1, readdata2);
   
   SignExtend se(instruction[15:0],Extend1);
   
   Mux2 m1(aluSrc,readdata2,Extend1,aluIn2);
   
   aluControl ac(instruction[5:0],aluOp,instruction[31:26],opration);
   //assign aluResult=readdata1+aluIn2;
   ALU a(readdata1,aluIn2,opration,aluResult,zero,lt,gt);
   DMemBank db(memRead,memWrite,aluResult[7:0],readdata2,readdataMem);
   
   Mux3 m2(readdataMem,aluResult,memToreg,writedata);
   
   Mux4 m3(pc+1'b1,(instruction[7:0]+pc+1'b1),zero&branch,resultmultiplexer);
   
   Mux4 m4(resultmultiplexer,instruction[7:0],jump,pc_next);


endmodule;
`timescale 1ns / 1ps
//fpga4student.com: FPGA projects, Verilog projects, VHDL projects
// Verilog project: Verilog code for 16-bit MIPS Processor
// Testbench Verilog code for 16 bit single cycle MIPS CPU  
 module tb_mips;  
      // Inputs  
      reg clk;  
      reg reset;
      wire[7:0] pc;
      wire [31:0] aluResult;
      wire [31:0]instruction;
      wire [31:0]readdata1,readdata2,writedata;
      wire jump,branch,memRead,memToreg,memWrite,aluSrc,regWrite,regDst;
      wire [7:0] resultmultiplexer;
      singleCycle uut (reset,clk,pc,aluResult,readdata1,readdata2,writedata, resultmultiplexer,instruction,jump,branch,memRead,memToreg,memWrite,aluSrc,regWrite,regDst);  
      initial begin  
           clk = 0;  
           forever #10 clk = ~clk;  
      end  
      initial begin  
           // Initialize Inputs  
           //$monitor ("register 3=%d, register 4=%d", reg3,reg4);  
           reset = 1;  
           // Wait 100 ns for global reset to finish  
           #10000;  
     reset = 0;  
           // Add stimulus here  
      end  
 endmodule

 module PIPE();
	 reg clk;
	 initial begin
		 clk=0;
	 end 
	 always begin 
		 #10
		 clk = ~clk;
	 end 
	 
	 
	wire [31:0] readDataRF1,readDataRF2,ALUresult,ALUin ,readDataMEM ,IRinst, imm, WBdest;
	wire [4:0] dest;
	wire [7:0] pc;
	wire [3:0] aluop;	 
	wire [1:0] aluControl; 
	wire regDst,memRead,memtoReg,memWrite,regWrite,aluSrc,gt,lt;
	reg[31:0] pcCur;
	reg [31:0]  Fetchir,IDimm,EXaluOut,EXbout,EXir, MEMreadData,MEMaluOUT,MEMir,IDa,IDb,IDir;
	reg EXmemread,EXmemTOreg,EXregWrite,EXzero,MEMmemToreg,MEMregWrite,EXmemWrite,IDMemWrite,IDaluSrc,IDmemRead,IDmemtoreg,IDregWrite,IDlessthan,IDgreaterthan;
	reg [4:0] Memdest,EXdest,IDdest;
	reg [3:0] IDaluOP;
	wire zero;
	reg[4:0] WBDESTINATION;
	
	
	initial begin
		pcCur=1;						  
		Fetchir=0;											 
		IDir=0;
		EXir=0;
		MEMir=0;
	end 
	
	
	assign 
	pc= pcCur[7:0];
	
	IMemBank IMB(1'b1,pc,IRinst);   // baraye marhaleye fetch 
	
	
	ControlAll control(Fetchir[31:26],aluControl,jump,branch,memRead,memtoReg,memWrite,aluSrc,regWrite,regDst);	 // baraye marhaleye decode 
	SignExtend immSE(Fetchir[15:0],imm); 
	Mux1 mux(Fetchir[20:16],Fetchir[15:11],regDst,dest); 
	RegFile Reg(clk, Fetchir[25:21], Fetchir[20:16],WBDESTINATION , WBdest,  MEMregWrite,readDataRF1,readDataRF2);
	
	
	Mux2 mux2(IDaluSrc,IDb,IDimm, ALUin);   // baraye marhaleye EXECUTE	
	ALU alu(IDa,ALUin,IDaluOP,ALUresult,zero,lt,gt);
	

DMemBank DMB(EXmemread, EXmemWrite, EXaluOut[7:0], EXbout, readDataMEM); // baraye marhaleye mem 
	
	Mux3 mux3(MEMreadData, MEMaluOUT, MEMmemToreg, WBdest);   // baraye marhaleye wb
		  
	always@(posedge clk)
		begin 	 
			//wb
			WBDESTINATION	=	Memdest;
	
			// mem 
			MEMregWrite=EXregWrite;
			MEMmemToreg=EXmemTOreg;
			MEMreadData=readDataMEM;
			MEMaluOUT=EXaluOut;
			MEMir=EXir;
			Memdest=EXdest;
			
			
			//EX 
			EXaluOut=ALUresult;
			EXbout=IDb;
			EXir=IDir;
			EXmemread=IDmemRead;
			EXmemWrite=IDMemWrite;
			EXmemTOreg=IDmemtoreg;
			EXregWrite=IDregWrite;								   
			EXzero=zero;
			EXdest=IDdest;
			
			
	
			
			
	// ID
	IDMemWrite=	memWrite;
	IDaluSrc=aluSrc;
	IDmemRead=memRead;
	IDmemtoreg=memtoReg;
	IDlessthan=lt;
	IDgreaterthan=gt;
	IDaluOP=aluop;
	IDa=readDataRF1;
	IDb=readDataRF2;
	IDir=Fetchir;
	IDdest=dest;
	IDimm=imm;
	
	
	//if
		Fetchir= IRinst;
		pcCur=pcCur+1;
		
	end 
	endmodule
	
/*	module Cstall(input clk,input [31:0] FD_IR,DE_IR,EM_IR,MW_IR,input[4:0] rs,rt destination,input wbdest,output reg stall);
	reg [4:0] dest,source,temp;
	reg  RE1,RE2,we,wm,ww;
	always@(posedge clk,FD_IR,DE_IR,EM_IR,MW_IR)begin
		write =0;
		RE1=0;
		RE2=0;
		stall=0; 
		
		begin 
				/*if(FD_IR[31:26]== 6'b101011 || 	 FD_IR[31:26]== 6'b001101 || FD_IR[31:26]== 6'b001010 || FD_IR[31:26]== 6'b001100 || FD_IR[31:26]== 6'b001000 || FD_IR[31:26]== 6'b100011 || FD_IR[31:26]== 6'b000000)
					begin 
						RE1=1;
						source= FD_IR[25:21];
					end 
					
				if(FD_IR[31:26]== 6'b101011 || 	 FD_IR[31:26]==0)
					RE2=1;																											   																					  
					temp=FD_IR[20:16]; */
					
		
	/*	if(FD_IR !=0)
			case(FD_IR[31:26])
				// rtype
				6'b0: 
				begin 
					RE1=1;
					RE2=1;
				end 
				// sw
				6'b101011:
				begin 
					RE1=1;
					RE2=1;
				end 
				// or1
				6'b001101:
				begin 
					
				RE1=1;
				RE2=0;
			end 
			// slti 
			6'b001010:
			begin
			    RE1=1;
				RE2=0;
			end 
			// andi
			6'b001100:
			begin 
				RE1=1;
				RE2=0;
			    end 
			// addi 
			6'b001000:
			begin 
				RE1=1;
				RE2=0;
			    end 
			
				//lw
				6'b100011:
				begin 
				RE1=1;
				RE2=0;
			    end 
				
			endcase	  
			if(DE_IR!=0) begin
				case(DE_IR[31:26])
					// rtype
				6'b0: 
				begin 
					we=1;
					source=DE_IR[15:11];
				end 
				// sw
				6'b101011:
				begin 
					we=0;
					source=0;
				end 
				// ori
				6'b001101:
				begin 
					
				we=1;
				source=DE_IR[20:16];
			end 
			// slti 
			6'b001010:
			begin
			    we=1;
				source=DE_IR[20:16];
			end 
			// andi
			6'b001100:
			begin 
				we=1;
				source=DE_IR[20:16];
			    end 
			// addi 
			6'b001000:
			begin 
				we=1;
				source=DE_IR[20:16];
			    end 
			
				//lw
				6'b100011:
				begin 
				we=1;
				source=DE_IR[20:16];
			    end 
					
					
					
				endcase
				
			end	
			
			if(EM_IR!=0)
				begin 
					case(EM_IR[31:26])
							
					// rtype
				6'b0: 
				begin 
					wm=1;
					temp=EM_IR[15:11];
				end 
				// sw
				6'b101011:
				begin 
					wm=0;
					temp=0;
				end 
				// ori
				6'b001101:
				begin 
					
				wm=1;
				temp=EM_IR[20:16];
			end 
			// slti 
			6'b001010:
			begin
			   wm=1;
				temp=EM_IR[20:16];
			end 
			// andi
			6'b001100:
			begin 
				wm=1;
				temp=EM_IR[20:16];
			    end 
			// addi 
			6'b001000:
			begin 
				wm=1;
				temp=EM_IR[20:16];
			    end 
			
				//lw
				6'b100011:
				begin 
					wm=1;
				temp=EM_IR[20:16];
				
			    end 
					
					
					
				endcase
				
			end	
			
			if(MW_IR!=0) begin
				
			end
			
			stall=((rs==source).we+(rs==)
						  
						  
			
			
			
				
				
endmodule	*/			
					
				
					
					
				
		
	
	
	
	
	
	
	
			
			
			
			
			
			
			
			
			
		
		
	
	 
 
 
 