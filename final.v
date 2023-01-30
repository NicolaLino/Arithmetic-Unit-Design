`timescale 1ns / 1ps
/* ********************************************************************************************************************************* */

/* 		
		Nicola Abu Shaibeh 1190843
		4 bit bit Arithmetic Unit
		12/08/2022
		The task is to design an Arithmetic Unit
		
*/ 

/* ********************************************************************************************************************************* */

module mux (out, a, b, c, d, s0, s1);
	output out;
	input a, b, c, d, s0, s1;
	wire sobar, s1bar, T1, T2, T3, T4;
	
	
	not #(3ns) (s0bar, s0), (s1bar, s1);
	and #(7ns) (T1, a, s0bar, s1bar), (T2, b, s0bar, s1),(T3, c, s0, s1bar), (T4, d, s0, s1);
	or #(7ns) (out, T1, T2, T3, T4);

endmodule

/* ********************************************************************************************************************************* */


module full_adder(a,b,cin,s,cout); // Full adder module for ripple carry 4 bit adder
	input a,b,cin;
	output cout,s;
	wire [2:0]w;
	
	xor #(12ns) x1(w[0],a,b);
	xor #(12ns) x2(s,w[0],cin);
	and #(8ns) a1(w[1],w[0],cin);
	and #(8ns) a2(w[2],a,b);
	or #(8ns) o1(cout,w[1],w[2]);
endmodule	



module ripple_carry_adder(a,b,s,cin,cout); 
	input [3:0]a;
	input [3:0]b;
	input cin;
	output [3:0]s;
	output cout;
	wire [3:0]C;
	
	full_adder f1(a[0],b[0],cin,s[0],C[0]);
	full_adder f2(a[1],b[1],C[0],s[1],C[1]);
	full_adder f3(a[2],b[2],C[1],s[2],C[2]);
	full_adder f4(a[3],b[3],C[2],s[3],cout);
endmodule

/* ********************************************************************************************************************************* */



module DFF (Q,D,CLK);
   output Q;
   input D,CLK;
   reg Q;
   always @(posedge CLK)
     Q = D;
endmodule


module registerIN(Q,D,CLK);
	parameter n = 15;
	input [n-1:0]D;
	input CLK;
	output [n-1:0]Q;
	
	
	genvar i;
	
	generate
	for (i=0;i<=n-1;i=i+1)
		begin:addbit
			DFF stage(Q[i],D[i],CLK);
		end
	endgenerate
endmodule  

module registerOUT(Q,D,CLK);
	parameter n = 5;
	input [n-1:0]D;
	input CLK;
	output [n-1:0]Q;
	
	
	genvar i;
	
	generate
	for (i=0;i<=n-1;i=i+1)
		begin:addbit
			DFF stage(Q[i],D[i],CLK);
		end
	endgenerate
endmodule 


/* ********************************************************************************************************************************* */

module ALU(a, b, d, s0, s1, cin, cout, CLK);	
	input [3:0] a, b;
	input s0, s1, cin, CLK;
	output [3:0] d;
	output cout;
	wire [3:0] A, B, Bnot, D;
	wire S0, S1, CIN, COUT;
	wire [3:0] c;
	reg [3:0] bnot;
	assign bnot = ~b;
	assign zero = 1'b0;
	assign one = 1'b1;
	
	// 0-3a 4-7b, 8-11!b 12s0 13s1 14cin
	registerIN ri({A,B,Bnot,S0,S1,CIN},{a, b, bnot, s0, s1, cin},CLK);
	
	mux m0(c[0], B[0], Bnot[0], zero, one, S0, S1);
	mux m1(c[1], B[1], Bnot[1], zero, one, S0, S1);
	mux m2(c[2], B[2], Bnot[2], zero, one, S0, S1);
	mux m3(c[3], B[3], Bnot[3], zero, one, S0, S1);
	ripple_carry_adder fr(A[3:0],c[3:0],D[3:0],CIN,COUT);
	
	registerOUT #(.n(18)) ro({cout, d},{COUT, D},CLK);

endmodule	



module Stimulus() ;
	reg [3:0] a,b;
	reg s0,s1,cin, CLK;
	wire [3:0] d;
	wire cout;
	ALU my(.a(a),.b(b),.d(d),.s0(s0),.s1(s1),.cin(cin), .cout(cout), .CLK(CLK));
	
	initial
		begin
		 CLK=0;
		repeat(2000)
		#100ns CLK = ~CLK;
		$finish;

	end
	
	initial	
	begin
		a = 4'b1010;
		b = 4'b0101;  
		
		{s0, s1, cin} = 3'b000;
		#100ns;
		repeat(7)	 
		#200ns {s0, s1, cin} = {s0, s1, cin} + 3'b001;
	 	
		
		$display("s0 = %b , s1 = %b , cin = %b \n",s0,s1,cin);
		$display("ANSWER = %b %b %b %b\n",d[3],d[2],d[1],d[0]);
		
	end
endmodule
	
/* ********************************************************************************************************************************* */
 module LookAhead(A,B,c_0,S,c_4);
	input [3:0]A,B;
	input c_0;
	output [3:0]S;
	output c_4;
	wire [3:0]P,G;
	wire [3:1]C;
	wire [3:0]w;
	wire [3:0]ig;
	//propagation and generator implementation
	xor #(11ns) x1(P[0],A[0],B[0]);	
	xor #(11ns) x2(P[1],A[1],B[1]);
	xor #(11ns) x3(P[2],A[2],B[2]);
	xor #(11ns) x4(P[3],A[3],B[3]);
	
	and #(7ns) a1(G[0],A[0],B[0]);
	and #(7ns) a2(G[1],A[1],B[1]);
	and #(7ns) a3(G[2],A[2],B[2]);
	and #(7ns) a4(G[3],A[3],B[3]);
	
	 //fulladder to get sum with carry out ignorant
   	full_adder f1(A[0],B[0],c_0,S[0],ig[0]);
	full_adder f2(A[1],B[1],C[1],S[1],ig[1]);
	full_adder f3(A[2],B[2],C[2],S[2],ig[2]);
	full_adder f4(A[3],B[3],C[3],S[3],ig[3]);
	
	//carries implementation
	and #(7ns) a5(w[0],P[0],c_0);
	or #(7ns) o1(C[1],G[0],w[0]);
	
	and #(7ns) a7(w[1],P[1],C[1]);
	and #(7ns) a8(w[2],P[2],C[2]);
	and #(7ns) a9(w[3],P[3],C[3]);
	
	or #(7ns) o2(C[2],G[1],w[1]);
	or #(7ns) o3(C[3],G[2],w[2]);
	or #(7ns) o4(c_4,G[3],w[3]);
	
endmodule

module ALU_LA(a, b, d, s0, s1, cin, cout, CLK);	
	input [3:0] a, b;
	input s0, s1, cin, CLK;
	output [3:0] d;
	output cout;
	wire [3:0] A, B, Bnot, D;
	wire S0, S1, CIN, COUT;
	wire [3:0] c;
	reg [3:0] bnot;
	assign bnot = ~b;
	assign zero = 1'b0;
	assign one = 1'b1;
	
	// 0-3a 4-7b, 8-11!b 12s0 13s1 14cin
	registerIN ri({A,B,Bnot,S0,S1,CIN},{a, b, bnot, s0, s1, cin},CLK);
	
	mux m0(c[0], B[0], Bnot[0], zero, one, S0, S1);
	mux m1(c[1], B[1], Bnot[1], zero, one, S0, S1);
	mux m2(c[2], B[2], Bnot[2], zero, one, S0, S1);
	mux m3(c[3], B[3], Bnot[3], zero, one, S0, S1);
	
	LookAhead la(A[3:0],c[3:0],CIN,D[3:0],COUT);
	registerOUT #(.n(18)) ro({cout, d},{COUT, D},CLK);

endmodule				   

module Stimulus_LA() ;
	reg [3:0] a,b;
	reg s0,s1,cin, CLK;
	wire [3:0] d;
	wire cout;
	ALULA myla(.a(a),.b(b),.d(d),.s0(s0),.s1(s1),.cin(cin), .cout(cout), .CLK(CLK));
	
	initial
		begin
		 CLK=0;
		repeat(2000)
		#100ns CLK = ~CLK;
		$finish;

	end
	
	initial	
	begin
		a = 4'b1010;
		b = 4'b0101;  
		
		{s0, s1, cin} = 3'b000;
		#100ns;
		repeat(7)	 
		#200ns {s0, s1, cin} = {s0, s1, cin} + 3'b001;
	 	
		
		$display("s0 = %b , s1 = %b , cin = %b \n",s0,s1,cin);
		$display("ANSWER = %b %b %b %b\n",d[3],d[2],d[1],d[0]);
		
	end
endmodule



/* ********************************************************************************************************************************* */

module TestGenerator(a, b, d, s0, s1, cin, cout, CLK);
	input CLK;
	output reg [3:0] a, b;
	output reg s0, s1, cin;
	output reg [3:0] d;
	output cout;
	assign bnot = ~b;
	always @(posedge CLK)
	
		begin
		case({s0,s1,cin})
		3'b000: d = a + b;
		3'b001: d = a + b + 1'b1;
		3'b010: d = a + bnot;
		3'b011: d = a + bnot + 1'b1;
		3'b100: d = a;
		3'b101: d = a + 1'b1;
		3'b110: d = a - 1'b1;
		3'b111: d = a;
		endcase	
		
		{s0, s1, cin} = {s0, s1, cin} + 3'b001;
		
		end
		
		
		initial
			begin
			a = 4'b0100;
			b = 4'b0010;  
			{s0, s1, cin} = 3'b000;
			end
endmodule 


module TestAnalayzer(CLK,genin,circin);
	input CLK;
	input [3:0]genin;
	input [3:0]circin;
	
	reg [8:0]check;
	
	always @(posedge CLK)
		begin
		if (check != circin)
			begin
				$display("Error Occured at TIME = %t",$time);
				//$finish;
			end
			
			check = genin;
		end
endmodule


module SelfTestALU();
	reg CLK;
	reg [3:0] a,b;
	reg s0,s1,cin;
	wire [3:0]circuit_out,generator_out;
	reg cout, Cout;
	
	generator g(a, b, generator_out, s0, s1, cin, cout, CLK);
	
	ALU al(a, b, circuit_out, s0, s1, cin, Cout, CLK);
	
	analayzer z(CLK,generator_out,circuit_out);
	
	initial 
		begin

			CLK = 0;
			repeat(200)
			#100ns CLK = ~CLK;
		end
		
endmodule 

module SelfTestALU_LA();
	reg CLK;
	reg [3:0] a,b;
	reg s0,s1,cin;
	wire [3:0]circuit_out,generator_out;
	reg cout, Cout;
	
	generator g(a, b, generator_out, s0, s1, cin, cout, CLK);
	
	ALU_LA la(a, b, circuit_out, s0, s1, cin, Cout, CLK); 
	
	analayzer z(CLK,generator_out,circuit_out);
	
	initial 
		begin

			CLK = 0;
			repeat(200)
			#100ns CLK = ~CLK;
		end
		
endmodule

/* ********************************************************************************************************************************* */
	