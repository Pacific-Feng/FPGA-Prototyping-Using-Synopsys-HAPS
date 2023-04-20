###### tags: `HAPS`
# FPGA-Prototyping-Using-Synopsys-HAPS Final Project Report

The final project of FPGA Prototyping Using Synopsys HAPS 2023

Github Link: [連結](https://github.com/Pacific-Feng/FPGA-Prototyping-Using-Synopsys-HAPS)

<br>

## **Presenter**
NTHU COSR 111501528 謝旻峰

<br>

## **Introduction**

本題請完成一圖像**卷積電路設計**(Image Convolutional Circuit Design，以下稱 CONV 電路)。

CONV 電路輸入為一灰階圖像，電路需完成3層(Layer)的運算流程，其順序為**Convolution(Layer 0) → Max-pooling(Layer 1) ) → Flatten(Layer 2)** 等共3層的運算處理流程，如 *圖一* 所示:

![](https://i.imgur.com/pBPz6ff.png)


首先在**Layer 0**中，輸入灰階圖像(尺寸為 64(寬)x64(高) pixels)需先經 zero-padding，接著進行採用2個濾鏡(或稱”核(Kernel)”)的圖像卷積(Convolution)運算，其Kernel尺寸為 3x3，接著再經過ReLU(Rectified Linear Unit)運算後方為 Layer 0的結果，故其結果為 2 張尺寸為64(寬)x64(高) pixels的圖。

**Layer1**要進行最大池化(max-pooling)運算，須採用 2x2的max-pooling視窗及步幅(stride)為2的規格進行。故結果將呈現 2 張尺寸為 32(寬) x 32(高) pixels 的圖。 

最後**Layer 2**則是進行平坦化(Flatten)處理，將 Layer 1 輸出的2張 32(寬) x 32(高) pixels的圖依規格排序成一個2048 (32x32x2)個訊號值的序列並輸出即可完成。

上述所有Layer，均可分層分次將處理結果寫回 testfixture 內建的記憶體中，每一Layer的輸出結果都有各自對應的記憶體存放空間用於放置輸出結果。

<br>

## **Block Diagram**

![](https://i.imgur.com/Y55LI7x.png)

<br>

## **The Schematics of FPGA_A and FPGA_B**

### 1. Total Structure

![](https://i.imgur.com/2KW4uvX.png)

<br>

### 2 Partition Structure

![](https://i.imgur.com/9zCPKwy.png)

<br>

### 3. FPGA_A

![](https://i.imgur.com/ea0hKFo.png)

### 4. FPGA_B

![](https://i.imgur.com/yzvtZGU.png)

<br>

#### &ensp;&ensp;&ensp;**(a) Layer 0**

![](https://i.imgur.com/74f9i3q.png)

<br>

##### &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;(i) CONV_TMR

![](https://i.imgur.com/skEhTgp.png)

##### &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;(ii) MCC

![](https://i.imgur.com/6jaOVVG.png)


<br>

#### &ensp;&ensp;&ensp;**(b) Layer 1**

![](https://i.imgur.com/iAYF8mJ.png)

<br>

#### &ensp;&ensp;&ensp;**(b) Layer 2**

![](https://i.imgur.com/dyHZEtM.png)


<br>

## **Timing Report**

### 1. FPGA_uA

#### (a) FB1_uA_timing_summary

![](https://i.imgur.com/XuY6816.png)


#### (b) FB1_uA_timing_summary

![](https://i.imgur.com/RV0dujH.png)

<br><br>

### 2. FPGA_uB

#### (a) FB1_uA_timing_summary

![](https://i.imgur.com/rwAELWJ.png)


#### (b) FB1_uA_timing_summary

![](https://i.imgur.com/B6MBqso.png)


