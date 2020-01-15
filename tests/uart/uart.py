"""
source: https://lab.whitequark.org/notes/2016-10-18/implementing-an-uart-in-verilog-and-migen/

instance: UART(clk_freq=4800, baud_rate=1200)

Removed _TestPads() Module, in UART() replaced serial variable with rx, tx signals 
    directly as inputs

"""


from migen import *
from migen.genlib.fsm import *


def _divisor(freq_in, freq_out, max_ppm=None):
    divisor = freq_in // freq_out
    if divisor <= 0:
        raise ArgumentError("output frequency is too high")

    ppm = 1000000 * ((freq_in / divisor) - freq_out) / freq_out
    if max_ppm is not None and ppm > max_ppm:
        raise ArgumentError("output frequency deviation is too high")

    return divisor


class UART(Module):
    def __init__(self, clk_freq, baud_rate):
        self.rx_data = Signal(8)
        self.rx_ready = Signal()
        self.rx_ack = Signal()
        self.rx_error = Signal()

        self.tx_data = Signal(8)
        self.tx_ready = Signal()
        self.tx_ack = Signal()

        self.rx = Signal(reset=1)
        self.tx = Signal()


        divisor = _divisor(freq_in=clk_freq, freq_out=baud_rate, max_ppm=50000)

        ###

        rx_counter = Signal(max=divisor)
        self.rx_strobe = rx_strobe = Signal()
        self.comb += rx_strobe.eq(rx_counter == 0)
        self.sync += \
            If(rx_counter == 0,
                rx_counter.eq(divisor - 1)
            ).Else(
                rx_counter.eq(rx_counter - 1)
            )

        self.rx_bitno = rx_bitno = Signal(3)
        self.submodules.rx_fsm = FSM(reset_state="IDLE")
        self.rx_fsm.act("IDLE",
            If(~self.rx,
                NextValue(rx_counter, divisor // 2),
                NextState("START")
            )
        )
        self.rx_fsm.act("START",
            If(rx_strobe,
                NextState("DATA")
            )
        )
        self.rx_fsm.act("DATA",
            If(rx_strobe,
                NextValue(self.rx_data, Cat(self.rx_data[1:8], self.rx)),
                NextValue(rx_bitno, rx_bitno + 1),
                If(rx_bitno == 7,
                    NextState("STOP")
                )
            )
        )
        self.rx_fsm.act("STOP",
            If(rx_strobe,
                If(~self.rx,
                    NextState("ERROR")
                ).Else(
                    NextState("FULL")
                )
            )
        )
        self.rx_fsm.act("FULL",
            self.rx_ready.eq(1),
            If(self.rx_ack,
                NextState("IDLE")
            ).Elif(~self.rx,
                NextState("ERROR")
            )
        )
        self.rx_fsm.act("ERROR",
            self.rx_error.eq(1))

        ###

        tx_counter = Signal(max=divisor)
        self.tx_strobe = tx_strobe = Signal()
        self.comb += tx_strobe.eq(tx_counter == 0)
        self.sync += \
            If(tx_counter == 0,
                tx_counter.eq(divisor - 1)
            ).Else(
                tx_counter.eq(tx_counter - 1)
            )

        self.tx_bitno = tx_bitno = Signal(3)
        self.tx_latch = tx_latch = Signal(8)
        self.submodules.tx_fsm = FSM(reset_state="IDLE")
        self.tx_fsm.act("IDLE",
            self.tx_ack.eq(1),
            If(self.tx_ready,
                NextValue(tx_counter, divisor - 1),
                NextValue(tx_latch, self.tx_data),
                NextState("START")
            ).Else(
                NextValue(self.tx, 1)
            )
        )
        self.tx_fsm.act("START",
            If(self.tx_strobe,
                NextValue(self.tx, 0),
                NextState("DATA")
            )
        )
        self.tx_fsm.act("DATA",
            If(self.tx_strobe,
                NextValue(self.tx, tx_latch[0]),
                NextValue(tx_latch, Cat(tx_latch[1:8], 0)),
                NextValue(tx_bitno, tx_bitno + 1),
                If(self.tx_bitno == 7,
                    NextState("STOP")
                )
            )
        )
        self.tx_fsm.act("STOP",
            If(self.tx_strobe,
                NextValue(self.tx, 1),
                NextState("IDLE")
            )
        )



