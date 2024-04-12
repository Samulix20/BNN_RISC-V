# Custom Instructions

This extension adds 2 new instructions to the RISC-V set, `genum rd` and `setseed rs1, rs2`. The execution latency of both instructions is 1 cycle.

The `genum` instruction generates a gaussian random value and stores it in the register `rd`.

The `setseed` instruction sets the internal value of the `rs1` LFSR to the value of the register `rs2`. This instruction can be used to change the value of any of the 12 LFSR. Because the generator is pipelined the generated numbers use the new seed after 4 cycles.

Both instructions use the R-Type encoding.

|         | funct7  | rs2   | rs1   | funct3 | rd    | opcode  |            |
|---------|---------|-------|-------|--------|-------|---------|------------|
| setseed | 0000000 | xxxxx | xxxxx | 000    | 00000 | 0001011 |            |
| MASK    | 1111111 | 00000 | 00000 | 111    | 11111 | 1111111 | 0xFE007FFF |
| MATCH   | 0000000 | 00000 | 00000 | 000    | 00000 | 0001011 | 0xB        |

|       | funct7  | rs2   | rs1   | funct3 | rd    | opcode  |            |
|-------|---------|-------|-------|--------|-------|---------|------------|
| genum | 0000000 | 00000 | 00000 | 001    | xxxxx | 0001011 |            |
| MASK  | 1111111 | 11111 | 11111 | 111    | 00000 | 1111111 | 0xFFFFF07F |
| MATCH | 0000000 | 00000 | 00000 | 001    | 00000 | 0001011 | 0x100B     |
