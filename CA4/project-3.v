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
module DMemBank(input memread, input memwrite, input [6:0] address, input [31:0] writedata, input clk, output reg [31:0] readdata);
 
  reg [31:0] mem_array [127:0];
  
  integer i;
  initial 
  begin
      for (i=0; i<128; i=i+1)   
     mem_array[i]=i;
  end
 
  always@(memread, memwrite, address, mem_array[address], writedata, posedge clk)
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
	  for (i=0; i<32; i=i+1)   
		  regfile[i] = i;
  end

  always @(writereg, writedata, RegWrite, posedge clk)
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
	  
	mem_array[1] = 32'b00000000101000100001100000000000;
	mem_array[2] = 32'b00000000011001000010100000000000;
	mem_array[3] = 32'b00001000000000000000000000000101;  //jump to 5
	mem_array[4] = 32'b00000000011001000010100000000000;
	mem_array[5] = 0;
	mem_array[6] = 0;
	mem_array[7] = 0;
	mem_array[8] = 0;
	mem_array[9] = 0;
	mem_array[10] = 0;
	/*mem_array[1] = 32'b00000000001001000001100000100000;
	mem_array[2] = 32'b10101100101000100000000000000000;
	mem_array[3] = 32'b00000000111001100100000000100010;
	mem_array[4] = 32'b00100001011010010000000000000001;
	mem_array[5] = 32'b00110010000100010000000000001010;
	mem_array[6] = 32'b00000000011100110111100000100101;
	mem_array[7] = 32'b10001100101100100000000000000000;  */
	/*mem_array[1] = 32'b00100000000001010000000000000000;
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
	mem_array[30] = 32'b00001000000000000000000000001101;*/
	
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
		if(select == 0) begin
			out = in2;
		end
	end
endmodule



module MUX32(input[31:0] in1, in2, input select, output reg [31:0] out);
	always@(in1, in2, select) begin
		if(select) begin
			out = in1;
		end
		if(select == 0) begin
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


module checkStall(input [31:0] FDinstr, DEinstr, EMinstr, MWinstr, input clk, output reg stallBit);
	
	reg [5:0] writeReg;	
	reg write, read1, read2;	 
	reg [5:0] readReg1, readReg2;
	
	
	always @(posedge clk, FDinstr, DEinstr, EMinstr, MWinstr) begin	 
		write = 0;
		read1 = 0;
		read2 = 0;	
		stallBit = 0;
		if(FDinstr != 0) begin 
						 
			if(FDinstr[31:26] == 0 || FDinstr[31:26] == 6'b101011 || FDinstr == 6'b100011 || FDinstr == 6'b001000 || FDinstr == 6'b001010|| FDinstr == 6'b001100 || FDinstr == 6'b001101 || FDinstr == 6'b000100 || FDinstr == 6'b000101) begin  
				read1 = 1;
				readReg1 = FDinstr[25:21];
			end
			if(FDinstr[31:26] == 0 || FDinstr[31:26] == 6'b101011 || FDinstr == 6'b000100 || FDinstr == 6'b000101) begin
				read2 = 1;
				readReg2 = FDinstr[20:16];
			end
			
		
			if(DEinstr != 0) begin	
				if(DEinstr[31:26] == 0)	begin
					writeReg = DEinstr[15:11]; 
					write = 1;
				end	
				if(DEinstr == 6'b100011 || DEinstr == 6'b001000 || DEinstr == 6'b001010|| DEinstr == 6'b001100 || DEinstr == 6'b001101) begin
					write = 1;
					writeReg = DEinstr[20:16];
				end
				if(read1 && write && readReg1 == writeReg) stallBit = 1; 
				if(read2 && write && readReg2 == writeReg) stallBit = 1;  
				write = 0;
				
				
			end
			if(EMinstr != 0) begin 
				if(EMinstr[31:26] == 0)	begin
					writeReg = EMinstr[15:11]; 
					write = 1;
				end	
				if(EMinstr == 6'b100011 || EMinstr == 6'b001000 || EMinstr == 6'b001010|| EMinstr == 6'b001100 || EMinstr == 6'b001101) begin
					write = 1;
					writeReg = EMinstr[20:16];
				end		
				if(read1 && write && readReg1 == writeReg) stallBit = 1; 
				if(read2 && write && readReg2 == writeReg) stallBit = 1;  
				write = 0;
			end
			if(MWinstr != 0) begin	
				if(MWinstr[31:26] == 0)	begin
					writeReg = MWinstr[15:11]; 
					write = 1;
				end	
				if(MWinstr == 6'b100011 || MWinstr == 6'b001000 || MWinstr == 6'b001010|| MWinstr == 6'b001100 || MWinstr == 6'b001101) begin
					write = 1;
					writeReg = MWinstr[20:16];
				end	  
				if(read1 && write && readReg1 == writeReg) stallBit = 1; 
				if(read2 && write && readReg2 == writeReg) stallBit = 1;  
				write = 0;
			end
			
		end			
		
	end	 
endmodule

module Equal(input [31:0] readData1, readData2, input clk, output reg zero);
	always @(posedge clk, readData1, readData2) begin
		if(readData1 == readData2)	begin
			zero = 0;					 
		end
		else begin 
			zero = 1;
		end
	end
endmodule

module single(); 
	reg clk;	
	
	//IF/ID REG
	reg[7:0] FDNPC;
	reg[31:0] FDinstr;		 
	
	//ID/EX REG
	reg DEjump, DEbranch, DEmemRead, DEmemToReg, DEmemWrite, DEALUSrc, DEregWrite, DElt, DEgt;	
	reg[3:0] DEALUOp; 
	reg[31:0] DEA, DEB, DEimm, DEinstr;	
	reg[4:0] DEwriteRegister; 
	reg[7:0] DENPC;
	
	//EX/MEM REG
	reg[7:0] EMNPC; 	
	reg[4:0] EMwriteRegister;
	reg[31:0] EMALUOut, EMB, EMinstr; 
	reg EMmemRead, EMmemWrite, EMmemToReg, EMregWrite, EMzero;
	
	//MEM/WB
	reg[31:0] MWreadData, MWALUOut, MWinstr;	
	reg MWregWrite, MWmemToReg;
	reg[4:0] MWwriteRegister;
	
	
	wire[31:0] WBwriteData;
	wire zero, stallBit;
	wire regDst, jump, branch, memRead, memToReg, memWrite, ALUSrc, regWrite, lt, gt;	
	wire[3:0] ALUOp; 
	wire[31:0] readData1, readData2, result, instr;	 	
	wire[4:0] writeRegister; 
	wire[31:0] immSE, memReadData, wb;
	wire[31:0] jumpAddress, sum, tmp0, ALUin; 

	wire[7:0] PC1, tmpPC, tmp1PC;
	reg[7:0] PC;

	initial begin
		PC = 1;
		clk = 0;   
		FDinstr = 0;
		DEinstr = 0;
		EMinstr = 0;
		MWinstr = 0;

	end				
	always begin
		#1000;
		clk = ~clk;
		
	end	
	always @(posedge clk) begin	 	
		//MEM
		MWreadData = memReadData;	
		MWALUOut = EMALUOut;	
		MWmemToReg = EMmemToReg;
		MWregWrite = EMregWrite; 
		MWwriteRegister = EMwriteRegister;	 
		MWinstr = EMinstr;
		
		//EX
		EMwriteRegister = DEwriteRegister; 	
		EMALUOut = result;
		EMB = DEB;			   
		EMmemRead = DEmemRead;
		EMmemWrite = DEmemWrite;
		EMmemToReg = DEmemToReg; 
		EMregWrite = DEregWrite;
		EMinstr = DEinstr;		

		//DECODE 		
		if(stallBit == 0) begin	 
			DEmemRead = memRead;
			DEmemToReg = memToReg;
			DEmemWrite = memWrite;
			DEALUSrc = ALUSrc;
			DEregWrite = regWrite;
			DElt = lt;
			DEgt = gt;
			DEALUOp = ALUOp;
			DEA = readData1;
			DEB = readData2;
			DEimm = immSE;	
			DEwriteRegister = writeRegister;
			DEinstr = FDinstr;
		end
		if(stallBit == 1) begin
			DEmemRead = 0;
			DEmemToReg = memToReg;
			DEmemWrite = 0;
			DEALUSrc = ALUSrc;
			DEregWrite = 0;
			DElt = lt;
			DEgt = gt;
			DEALUOp = ALUOp;
			DEA = 0;
			DEB = 0;
			DEimm = 0;	
			DEwriteRegister = 0;
			DEinstr = 0;
		end
		
		
		//FETCH		 
		if(stallBit == 0 && !((zero && branch) || jump)) begin
			PC = tmp1PC;
			FDNPC = PC1;	
			FDinstr = instr;  	
		end	
		if(stallBit == 0 && ((zero && branch) || jump)) begin
			PC = tmp1PC;
			FDNPC = 0;	
			FDinstr = 0;  	
		end
		
		
		
	end	  	  
	//FETCH
	MUX32 u1(sum, PC1, zero & branch, tmpPC);	 
	MUX32 u331(instr[7:0], tmpPC, jump, tmp1PC);
	Adder u2(PC, 8'b00000001, PC1);  
	IMemBank memBank(PC,  instr);  	
	
	//DECODE
	Control cont(FDinstr[31:26], FDinstr[5:0], regDst, jump, branch, memRead, memToReg, memWrite, ALUSrc, regWrite, ALUOp);
	RegFile regFile(clk, FDinstr[25:21], FDinstr[20:16], MWwriteRegister, WBwriteData, MWregWrite, readData1, readData2);
	SE se1(FDinstr[15:0], immSE);	
	MUX5 m2(FDinstr[15:11], FDinstr[20:16], regDst, writeRegister);	
	checkStall m123(FDinstr, DEinstr, EMinstr, MWinstr, clk, stallBit);	
	Adder u5(FDNPC, FDinstr[7:0], sum);	
	Equal m333(readData1, readData2, clk, zero);
																										   
	//EX
	MUX32 m3(DEimm, DEB, DEALUSrc, ALUin); 
	ALU u33(DEA, ALUin, DEALUOp, result, zero, lt, gt); 
	
	
	//MEM  
	DMemBank dataMem(EMmemRead, EMmemWrite, EMALUOut, EMB, clk, memReadData);
	
	//WB
	MUX32 u44(MWreadData, MWALUOut, MWmemToReg, WBwriteData);
	
	

	
	
endmodule


