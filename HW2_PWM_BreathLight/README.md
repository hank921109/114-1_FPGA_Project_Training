## 設計PWM控制之呼吸燈
利用HW1_TwoCounter的計數器及FSM狀態幾設計，完成PWM控制LED燈。
**HW2_BreathLight.vhd(主程式)**中有宣告 **P** ，用來抓取pwm_pedge(PWM的正緣訊號)，當抓取到P個pwm_pedge時，會在alreadyP_PWM_cycles下一個clock狀態輸出為1。設定這個的用意是為了PWM切換亮暗速度過快，會看不出來波形之變化。

### 利用HW1_TwoCounter的計數器，模擬PWM訊號。(out_led為輸出後的呼吸燈的工作週期)
upbnd1p與upbnd2p為互補（相加為2^8 = 255）
- upbnd1p：越大LED越暗，工作週期愈短。
- upbnd2p：越大LED越亮，工作週期愈長。
- 可以看FPGA板子是高電位觸發還是低電位觸發，來定義upbnd（upper bound上限值）。

### FSM兩種狀態（當LED最亮or最暗的時候切換狀態）
- gettingBright(state1)：當upbnd1 = 255時，將狀態切換為gettingDrak。
- gettingDrak  (state2)：當upbnd2 = 0  時，將狀態切換為gettingBright。


![image1](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW2_PWM_BreathLight/images/1.png)
![image2](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW2_PWM_BreathLight/images/2.png)
![image3](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW2_PWM_BreathLight/images/3.png)
![image4](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW2_PWM_BreathLight/images/4.png)
![image5](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW2_PWM_BreathLight/images/5.png)
![image6](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW2_PWM_BreathLight/images/6.png)
![image7](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW2_PWM_BreathLight/images/7.png)
![image8](https://github.com/hank921109/114-1_FPGA_Project_Training/blob/main/HW2_PWM_BreathLight/images/8.png)
