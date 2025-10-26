## HW1：利用兩個計數器並使用FSM來切換狀態

設計兩個計數器，Counter1從0數到9；Counter2從253倒數79。
並設計FSM兩種狀態，使計數器可以按照規則運作。
- S0：Counter1從0數到9，Counter2維持253，狀態轉換到S1。
- S1：Counter1維持，Counter2從253倒數79，狀態轉換成S0。
- 其中Counter1的**0**必須和Counter2的**253**重疊。


![PIC1](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW1_TwoCounter/images/picture1.png)
![PIC2](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW1_TwoCounter/images/picture2.png)
