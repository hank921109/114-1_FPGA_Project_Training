HW1：利用兩個計數器和FSM來切換狀態

S0：Counter1從0數到9，Counter2維持253，狀態轉換到S1。
S1：Counter1維持，Counter2從253倒數79，狀態轉換成S0。
其中Counter1的0必須和Counter2的253重疊。