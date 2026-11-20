`ifndef SPI_SEQUENCE_SV
`define SPI_SEQUENCE_SV

class spi_base_seq extends uvm_sequence #(spi_item);
  `uvm_object_utils(spi_base_seq)

  int unsigned num_txns = 10;

  function new(string name = "spi_base_seq");
    super.new(name);
  endfunction

  task body();
    spi_item req;
    repeat (num_txns) begin
      req = spi_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

`endif
