module ALU(input [31:0] data1,data2,input [3:0] aluoperation,output reg [31:0] result,output reg zero, lt, gt);

  always@(aluoperation,data1,data2)
  begin
    case (aluoperation)
      4'b0000 : result = data1 + data2; // ADD
      4'b0001 : result = data1 - data2; // SUB
      4'b0010 : result = data1 & data2; // AND
      4'b0011 : result = data1 | data2; // OR
      4'b0100 : result = data1 ^ data2; // XOR	
	  4'b1111 : result = data1 < data2 ? 1'b1 : 0'b0; //SLT
      default : result = data1 + data2; // ADD
    endcase
    
    if(data1>data2)
      begin
       gt = 1'b1;
       lt = 1'b0; 
      end else if(data1<data2)
      begin
       gt = 1'b0;
       lt = 1'b1;  
      end
      
    if (result==32'd0) zero=1'b1;
    else zero=1'b0;
     
  end
  

endmodule



//memory unit
module DMemBank(input memread, input memwrite, input [6:0] address, input [31:0] writedata, output reg [31:0] readdata);
 
  reg [31:0] mem_array [127:0];
  
  integer i;
  initial 
  begin
      for (i=100; i<110; i=i+1)   
     mem_array[i]=i*10;
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




module RegFile (clk, readreg1, readreg2, writereg, writedata, RegWrite, readdata1, readdata2);
  input [4:0] readreg1, readreg2, writereg;
  input [31:0] writedata;
  input clk, RegWrite;
  output [31:0] readdata1, readdata2;
  reg [31:0] regfile [31:0];   
  integer i;
  initial begin
	  regfile[4] = 100;
	  regfile[0]=0;
  end

  always @(posedge clk)
  begin
    regfile[0]=0;
    if (RegWrite) 
	 regfile[writereg] <= writedata;
  end
   
  	assign readdata1 = regfile[readreg1];
        assign readdata2 = regfile[readreg2];
endmodule



//memory unit
module IMemBank(input [7:0] address, output reg [31:0] readdata);
 
  reg [31:0] mem_array [255:0];
  
  integer i;
  initial begin
	mem_array[1] = 32'b00100000000001010000000000000000;
	mem_array[2] = 32'b00100000000001100111111111111111;
	mem_array[3] = 32'b00100000000001110000000000000000;
	mem_array[4] = 32'b00101000111010000000000000001010;
	mem_array[5] = 32'b00010000000010000000000000011001;
	mem_array[6] = 32'b00100000101000010000000000000000;
	mem_array[7] = 32'b00000000100001110100100000100000;
	mem_array[8] = 32'b10001101001000100000000000000000;
	mem_array[9] = 32'b00001000000000000000000000010011;
	mem_array[10] = 32'b00100000011001010000000000000000;
	mem_array[11] = 32'b00100000110000010000000000000000;
	mem_array[12] = 32'b00001000000000000000000000011001;
	mem_array[13] = 32'b00100000011001100000000000000000;
	mem_array[14] = 32'b00100000111001110000000000000001;
	mem_array[15] = 32'b00001000000000000000000000000100;

	mem_array[19] = 32'b00000000001000100101000000101010;
	mem_array[20] = 32'b00010001010000000000000000000010;
	mem_array[21] = 32'b00100000010000110000000000000000;
	mem_array[22] = 32'b00001000000000000000000000001010;
	mem_array[23] = 32'b00100000001000110000000000000000;
	mem_array[24] = 32'b00001000000000000000000000001010;
	mem_array[25] = 32'b00000000001000100101000000101010;
	mem_array[26] = 32'b00010001010000000000000000000010;
	mem_array[27] = 32'b00100000001000110000000000000000;
	mem_array[28] = 32'b00001000000000000000000000001101;
	mem_array[29] = 32'b00100000010000110000000000000000;
	mem_array[30] = 32'b00001000000000000000000000001101;
	
  end
 
  always@(address)
  begin
      readdata=mem_array[address];
  end

endmodule


module Control(input [5:0] opcode, func, output reg regDst, jump, branch, memRead, memToReg, memWrite, ALUSrc, regWrite, output reg [3:0] ALUOp);

	always @(opcode, func) begin	//R Type
    	if(opcode == 6'b000000) begin
			regDst = 1;
			jump = 0;
			branch = 0;
			memRead = 0;
			memToReg = 0;
			memWrite = 0;																																	
			ALUSrc = 0;
			regWrite = 1; 
			case (func) 
		      6'b100000 : ALUOp = 4'b0000; // ADD
		      6'b100100 : ALUOp = 4'b0010; // AND
		      6'b100101 : ALUOp = 4'b0011; // OR
		      6'b101010 : ALUOp = 4'b1111; // SLT
		      6'b100010 : ALUOp = 4'b0001; // SUB  
			  default : ALUOp = 4'b0000; 
   	 		endcase 
		end	 
		if(opcode == 6'b000010) begin //jump
			jump = 1;
			memRead = 0;
			memWrite = 0;
			regWrite = 0;
		end
		if(opcode == 6'b101011) begin //SW
			jump = 0;
			branch = 0;
			memRead = 0;
			ALUOp = 4'b0000;
			memWrite = 1;
			ALUSrc = 1;
			regWrite = 0;
		end
		if(opcode == 6'b100011) begin //LW
			regDst = 0;
			jump = 0;
			branch = 0;
			memRead = 1;
			memToReg = 1;
			ALUOp = 4'b0000;
			memWrite = 0;
			ALUSrc = 1;
			regWrite = 1;
		end
		if(opcode == 6'b001000) begin //ADDI
			regDst = 0;
			jump = 0;
			branch = 0;									 
			memRead = 0;
			memToReg = 0;
			ALUOp = 4'b0000;
			memWrite = 0;
			ALUSrc = 1;
			regWrite = 1;
		end
		if(opcode == 6'b001010) begin //SLTI
			regDst = 0;
			jump = 0;
			branch = 0;									 
			memRead = 0;
			memToReg = 0;
			ALUOp = 4'b1111;
			memWrite = 0;
			ALUSrc = 1;
			regWrite = 1;
		end
		if(opcode == 6'b001100) begin //ANDI
			regDst = 0;
			jump = 0;
			branch = 0;									 
			memRead = 0;
			memToReg = 0;
			ALUOp = 4'b0010;
			memWrite = 0;
			ALUSrc = 1;
			regWrite = 1;
		end
		if(opcode == 6'b001101) begin //ORI
			regDst = 0;
			jump = 0;
			branch = 0;									 
			memRead = 0;
			memToReg = 0;
			ALUOp = 4'b0011;
			memWrite = 0;
			ALUSrc = 1;
			regWrite = 1;
		end
		if(opcode == 6'b000100) begin //BEQ
			jump = 0;
			branch = 1;
			memRead = 0; 
			ALUOp = 4'b0001;
			memWrite = 0;
			ALUSrc = 0;
			regWrite = 0;
		end
		if(opcode == 6'b000101) begin //BNE
			jump = 0;
			branch = 1;
			memRead = 0; 
			ALUOp = 4'b0001;
			memWrite = 0;
			ALUSrc = 0;
			regWrite = 0;
		end
		
		
  	end		  
endmodule 

module MUX5(input[5:0] in1, in2, input select, output reg [5:0] out);
	always@(in1, in2, select) begin
		if(select) begin
			out = in1;
		end
		else begin
			out = in2;
		end
	end
endmodule



module MUX32(input[31:0] in1, in2, input select, output reg [31:0] out);
	always@(in1, in2, select) begin
		if(select) begin
			out = in1;
		end
		else begin
			out = in2;
		end
	end
endmodule

module SE(input [15:0] in, output reg [31:0] out);	  
	integer i;
	always@(in) begin   
		out[15:0] = in;
		for (i=16; i<32; i=i+1)
			out[i] = in[15];
	end
endmodule

module SE1(input [25:0] in, output reg [31:0] out);	  
	integer i;
	always@(in) begin   
		out[25:0] = in;
		for (i=26; i<32; i=i+1)
			out[i] = in[25];
	end
endmodule

module SL2(input[31:0] in, output reg[31:0] out);
	always@(in)begin
		out = in << 2;
	end
endmodule

module Adder(input [7:0] data1, data2, output reg [31:0] result);

  always@(data1, data2) begin
    result = data1 + data2;
  end
endmodule





module single(); 
	reg clk;
	wire regDst, jump, branch, memRead, memToReg, memWrite, ALUSrc, regWrite, zero, lt, gt;
	wire[3:0] ALUOp; 
	wire[31:0] readData1, readData2, result, instr;	 	
	wire[4:0] writeRegister; 
	wire[31:0] immSE, memReadData, wb;
	wire[31:0] jumpAddress, sum, tmp0, ALUin; 

	wire[7:0] PC1, newPC;
	reg[7:0] PC;

	initial begin
		PC = 1;
		clk = 0;
	end				
	always begin
		#1000;
		clk = ~clk;
		
	end	
	always @(posedge clk) begin
		  PC = newPC ;
	end
	IMemBank memBank(PC,  instr);   
	Control cont(instr[31:26], instr[5:0], regDst, jump, branch, memRead, memToReg, memWrite, ALUSrc, regWrite, ALUOp);
	MUX5 m2(instr[15:11], instr[20:16], regDst, writeRegister);
	RegFile regFile(clk, instr[25:21], instr[20:16], writeRegister, wb, regWrite, readData1, readData2);
	SE se1(instr[15:0], immSE);
	MUX32 m3(immSE, readData2, ALUSrc, ALUin);
	ALU u1(readData1, ALUin, ALUOp, result, zero, lt, gt); 
	DMemBank dataMem(memRead,memWrite, result, readData2, memReadData);	   
	MUX32 m1(memReadData, result, memToReg, wb);				  
	
	Adder u2(PC, 8'b00000001, PC1);   
	SE1 se111(instr[25:0], jumpAddress);
	Adder u5(PC1, immSE, sum);

	MUX u66(sum, PC1, zero & branch, tmp0);
	MUX u7(jumpAddress, tmp0, jump, newPC);	
	
	
	
endmodule

/*
module tb; 
	reg clk;
	initial begin
		clk = 0;
	end
	
	always begin
		clk = ~clk;
		#1000;
	end	   
	single u(clk);
endmodule*/