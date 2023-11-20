`ifndef AXIS_VIP_VH
`define AXIS_VIP_VH

// драйвер для data1_i AXI-Stream Slave интерфейса
`define AXIS_SLAVE_DRIVER(aclk, tready, tdata, tvalid, min_delay, max_delay, max_value, seed)   \
    while(1) begin                                                                              \
        tvalid <= 1'b0;                                                                         \
        repeat($urandom(seed) % (max_delay + 1) + min_delay)                                    \
            @(posedge aclk);                                                                    \
        tdata <= $urandom(seed) % (max_value + 1);                                              \
        tvalid <= 1'b1;                                                                         \
        @(posedge aclk);                                                                        \
        while (!tready)                                                                         \
            @(posedge aclk);                                                                    \
    end

// драйвер для AXI-Stream Master интерфейса
`define AXIS_MASTER_DRIVER(aclk, tready, min_delay, max_delay, seed) \
    while (1) begin                                                  \
        tready <= 1'b0;                                              \
        repeat($urandom(seed) % (max_delay + 1) + min_delay)         \
            @(posedge aclk);                                         \
        tready <= 1'b1;                                              \
        @(posedge aclk);                                             \
        repeat($urandom(seed) % (max_delay + 1) + min_delay)         \
            @(posedge aclk);                                         \
    end

// монитор для AXI-Stream интерфейса
`define AXIS_MONITOR(aclk, tvalid, tready, handshake_event)     \
    while (1) begin                                             \
        @(posedge aclk);                                        \
        if (tready && tvalid)                                   \
            -> handshake_event;                                 \
    end

`endif