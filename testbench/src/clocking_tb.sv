/*s_md
# Description
This testbench introduces clocking of sequences, porperties, assertions,
and assumptions.

# DUT
This testbench uses a round robin arbiter as a context for introducing the
concepts. The dut design file is -
[sva_basics/design/src/rr_arbiter.sv](https://github.com/openformal/sva_basics/blob/master/design/docs/rr_arbiter.md)

e_md*/

//s_sv
module clocking_tb();

  logic clock;
  logic reset;

  parameter CLIENTS = 32;

  logic [CLIENTS-1:0] request;
  logic [CLIENTS-1:0] grant;

//md In this testbench stall is disabled
  wire stall = 1'b0;

  rr_arbiter #(.CLIENTS(32)) dut (
                  .request (request),
                  .grant   (grant),
                  .stall   (stall),
                  .clock   (clock),
                  .reset   (reset));

  req4_stable_till_gnt: assume property (
    @(posedge clock) request[4] && !grant[4] |-> ##1 request[4]
  );

/*s_md
# Overview
Concurrent SVAs need to have a clock. This testbench covers the single clock
scenario. The clock can be specified in the assertion, property or sequence.

## Clocking in assertion
e_md*/
  sequence gnt_in_31_cycles_S1;
    ##[0:31] grant[4];
  endsequence;

  property gnt4_in_31_cycles_P1;
    request[4] |-> gnt_in_31_cycles_S1;
  endproperty;

  gnt4_in_31_cycles_AT1: assert property (
    @(posedge clock) (gnt4_in_31_cycles_P1)
  );

/*s_md
## Clocking in property
This method is commonly recommended. It allows the sequences
to be reusable;
e_md*/

  sequence gnt4_in_31_cycles_S2;
    ##[0:31] grant[4];
  endsequence;

  property gnt4_in_31_cycles_P2;
    @(posedge clock) request[4] |-> gnt4_in_31_cycles_S2;
  endproperty;

  gnt4_in_31_cycles_AT2: assert property (gnt4_in_31_cycles_P2);

//md ## Clocking in sequence
  sequence gnt4_in_31_cycles_S3;
    ##[0:31] grant[4];
  endsequence;

  property gnt4_in_31_cycles_P3;
    @(posedge clock) request[4] |-> gnt4_in_31_cycles_S3;
  endproperty;

  gnt4_in_31_cycles_AT3: assert property (gnt4_in_31_cycles_P3);


/*s_md
## Clocking blocks
### Named clocking block
e_md*/
  clocking pe_clock
    @(posedge clock);
  endclocking

  sequence gnt4_in_31_cycles_S4;
    ##[0:31] grant[4];
  endsequence;

  property gnt4_in_31_cycles_P4;
    request[4] |-> gnt4_in_31_cycles_S4;
  endproperty;

  gnt4_in_31_cycles_AT4: assert property (
    @(pe_clock) (gnt4_in_31_cycles_P4)
  );
//md ### Default clocking block
  default clocking
    @(posedge clock);
  endclocking
  
  sequence gnt4_in_31_cycles_S5;
    ##[0:31] grant[4];
  endsequence;

  property gnt4_in_31_cycles_P5;
    request[4] |-> gnt4_in_31_cycles_S5;
  endproperty;

  gnt4_in_31_cycles_AT5: assert property (gnt4_in_31_cycles_P5);

endmodule
//e_sv
