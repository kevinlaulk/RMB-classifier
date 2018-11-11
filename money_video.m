clc,clear
close all
%%
%1920*108
%mov格式
%该算法与神经网络算法类似，简化了一些，速度提高
shot_width=1920;width2=shot_width/4;
shot_height=1080;height2=shot_height/2;
sum_percent=0.1*shot_height;
rectangle_x=shot_width/40;
rectangle_y=shot_height/40;
pr_rato=[2,6];%长宽比
supplement_y=10;%补偿量
supplement_x=10;
rectangle_width=[shot_width/10,shot_width*0.95];
rectangle_hight=[shot_height/20,shot_height*0.8];
%%
flag_video=0;%是否重新读取视频

if flag_video==1
[filename,pathname]=...
    uigetfile({'*.*' },'选择视频');
str=[pathname filename];
count2=0;%计时触发识别
mov = VideoReader( str );%读取视频
for i=1:mov.NumberOfFrames
    frame = read( mov, i );
    count2; %显示触发时间
%     figure(1),imshow(frame);
%     hold on;plot([width2,width2],[1,height]);hold off;drawnow;%显示截图
    
if i==1%第一帧处理
    frame0=im2bw(frame);%触发阈值确定 %转为二值图
    sum_frame0=sum(frame0(:,width2));%触发行二值图求和
    sum_frame1=sum_frame0;%防止触发识别事件
elseif i==2%第二帧处理
    frame1 = im2bw(frame);%触发阈值确定 %转为二值图
    sum_frame1=sum(frame1(:,width2));
else  %其余以后帧处理
    sum_frame0=sum_frame1;
    frame1 = im2bw(frame);%触发阈值确定 %转为二值图
    sum_frame1=sum(frame1(:,width2));
%     figure(2),imshow(frame1);
%     hold on;plot([width2,width2],[1,height]);hold off;drawnow;%显示二值截图
end
sum_diff=abs(sum_frame1-sum_frame0);
if sum_diff>sum_percent
    im=frame;
    file_name1=strcat('.\snapshot\snapshot','.jpg');%截图路径
    imwrite(frame,file_name1,'jpg');%保存截图
    break
end
end
end
if flag_video==0
    file_name=strcat('.\snapshot\5','.jpg');%%%%%%%%%%%%===========此处修改截图号，在不读取视频时，用于静态读取照片
    rgb_image=imread(file_name);
    im=rgb_image;
end

%%
%========================预处理====================
figure,imshow(im),title('snapshot');%截图 RGB
bw=im2bw(im);
figure,imshow(bw),title('二值图')%截图二值图
grd=edge(bw,'canny');%用canny算子识别强度图像中的边界
figure,imshow(grd);title('图像边缘提取');%输出图像边缘
bg1=imclose(bw,strel('rectangle',[rectangle_x,rectangle_y]));%闭运算
figure,imshow(bg1);title(['图像闭运算[',num2str(rectangle_x),',',num2str(rectangle_y),']']);%输出闭运算的图像
%%
%========================连通域处理===============
%对二值图像进行区域提取，并计算区域特征参数。进行区域特征参数比较，提取车牌区域
[L,num] = bwlabel(bg1,8);%标注二进制图像中已连接的部分（L为连通区域矩阵，num为连通区域数目）
Feastats = regionprops(L,'basic');%计算图像区域的系列特征尺寸（'Area'是标量，计算出在图像各个区域中像素总个数。'BoundingBox'是1行ndims(L)*2列的向量，即包含相应区域的最小矩形。BoundingBox 形式为 [ul_corner width]，这里 ul_corner 以 [x y z ...] 的坐标形式给出边界盒子的左上角、boxwidth 以 [x_width y_width ...] 形式指出边界盒子沿着每个维数方向的长度。）
                                  %'Centroid'是1行ndims(L)列的向量，给出每个区域的质心（重心）。
Area=[Feastats.Area];%区域面积
BoundingBox=[Feastats.BoundingBox];%[x y width height]车牌的框架大小
RGB_image2= label2rgb(L, 'spring', 'k', 'noshuffle'); %标志图像向RGB图像转换
figure,imshow(RGB_image2);title('图像彩色标记');%输出框架的彩色图像
%%
%======================图像切割=================
%计算筛选后的连通区域的长宽比！！！！！！！！
if num~=1
l=0;
startcol=zeros(1,num);
startrow=zeros(1,num);
width=zeros(1,num);
hight=zeros(1,num);
for k= 1:num
    l=l+1;   
    startcol(k)=BoundingBox((l-1)*4+1)-supplement_x;%连通区域左上角坐标x
    startrow(k)=BoundingBox((l-1)*4+2)-supplement_y;%连通区域左上角坐标y
    if startcol(k)<0||startrow(k)<0
        l=l-1;
        continue

    end
    width(k)=BoundingBox((l-1)*4+3)+supplement_x;%宽
    hight(k)=BoundingBox((l-1)*4+4)+supplement_y;%高
    if width(k)<rectangle_width(1)||width(k)>rectangle_width(2)|| hight(k)<rectangle_hight(1) || hight(k)>rectangle_hight(2)%框架的宽度和高度的范围
        l=l-1;
        continue
    end
    rato=width(k)/hight(k);%计算车牌长宽比
    if rato>pr_rato(1) && rato<pr_rato(2)   
        break;
    end
end
    endrow=startrow(l)+hight(l)+supplement_y;
    endcol=startcol(l)+width(l)+supplement_x;
else
    l=1;
    startcol=BoundingBox((l-1)*4+1)-supplement_x;%连通区域左上角坐标x
    startrow=BoundingBox((l-1)*4+2)-supplement_y;%连通区域左上角坐标y
    width=BoundingBox((l-1)*4+3)+supplement_x;%宽
    hight=BoundingBox((l-1)*4+4)+supplement_y;%高
    endrow=startrow(l)+hight(l)+supplement_y;
    endcol=startcol(l)+width(l)+supplement_x;
    if startcol<1
        startcol=1;
    end
    if startcol<1
        startcol=1;
    end
    if endrow>shot_height
        endrow=shot_height;
    end
    if endcol>shot_width
        endcol=shot_width;
    end
end
rgb_sub1=rgb_image(startrow(l):endrow,startcol(l):endcol,:);%取彩图子图
gray1=rgb2gray(rgb_sub1);
sbw1=im2bw(rgb_sub1);%获取车牌二值子图
grd1=edge(sbw1,'canny');%获取车牌边界子图
figure,subplot(3,1,1),imshow(rgb_sub1);title('纸币子图');%显示纸币的二值图
subplot(3,1,2),imshow(sbw1);title('纸币二值子图');%显示纸币的二值图
subplot(3,1,3),imshow(grd1);title('纸币边界子图');%显示纸币的边界
%%
%===========================图像识别============
R=rgb_sub1(:,:,1);
G=rgb_sub1(:,:,2);
B=rgb_sub1(:,:,3);
[sub_height,sub_width]=size(gray1);
sub_width_line=round([sub_width/5,sub_width*2/5,sub_width*3/5,sub_width*4/5]);
sub_height_line=round([sub_height/3,sub_height*2/3]);
figure,imshow(rgb_sub1)
hold on;
for i=1:4
    plot([sub_width_line(i),sub_width_line(i)],[1,sub_height])
end
for i=1:2
    plot([1,sub_width],[sub_height_line(i),sub_height_line(i)])
end
hold off

for i=1:4
    R_count(i)=sum(R(:,sub_width_line(i)));
    G_count(i)=sum(G(:,sub_width_line(i)));
    B_count(i)=sum(B(:,sub_width_line(i)));
end
for i=1:2
    R_count2(i)=sum(R(sub_height_line(i),:));
    G_count2(i)=sum(G(sub_height_line(i),:));
    B_count2(i)=sum(B(sub_height_line(i),:));
end

%%
load RGB_list R_count_list G_count_list B_count_list R_count2_list G_count2_list B_count2_list %加载数据
liccode1={'1','1','5','0.5','5','10','10','20','20','50','50','100','100'}; %建立自动识别字符代码表  
liccode2=char(['反','正','反','反','正','反','正','反','正','反','正','反','正']); %建立自动识别字符代码表  
length_code=length(liccode1);
add_rgb=zeros(1,13);
for k=1:13
    add_rgb(k)=0;
    for i=1:4
    add_rgb(k)=add_rgb(k)+abs(R_count_list(i,k)-R_count(i));
    add_rgb(k)=add_rgb(k)+abs(G_count_list(i,k)-G_count(i));
    add_rgb(k)=add_rgb(k)+abs(B_count_list(i,k)-B_count(i));
    end
    for i=1:2
    add_rgb(k)=add_rgb(k)+abs(R_count2_list(i,k)-R_count2(i));
    add_rgb(k)=add_rgb(k)+abs(G_count2_list(i,k)-G_count2(i));
    add_rgb(k)=add_rgb(k)+abs(B_count2_list(i,k)-B_count2(i));
    end
end
figure,bar(add_rgb),title('误差表(模拟神经网络算法)');
[~,findc]=min(add_rgb);%误差最小值位置
RegCode1=liccode1(findc(1));%最符合的标准子图位置
RegCode2=liccode2(findc(1));%最符合的标准子图位置
result=strcat('识别结果：',RegCode1,RegCode2);
figure,imshow(rgb_sub1);title(result)