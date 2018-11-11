clc,clear
close all
%%
%1920*108
%mov��ʽ
%���¼���ʶ�����ݱ�
shot_width=1920;width2=shot_width/4;
shot_height=1080;height2=shot_height/2;
sum_percent=0.1*shot_height;
rectangle_x=shot_width/40;
rectangle_y=shot_height/40;
pr_rato=[2,6];%�����
supplement_y=10;%������
supplement_x=10;
rectangle_width=[shot_width/10,shot_width*0.95];
rectangle_hight=[shot_height/20,shot_height*0.8];
flag_video=0;

for count=1:13
if flag_video==0
    file_name=strcat('.\snapshot\',num2str(count),'.jpg');%%%%%%%%%%%%�˴��޸Ľ�ͼ��
    rgb_image=imread(file_name);
    im=rgb_image;
end

%%
%========================Ԥ����====================
figure,imshow(im),title('snapshot');%��ͼ RGB
bw=im2bw(im);
figure,imshow(bw),title('��ֵͼ')%��ͼ��ֵͼ
grd=edge(bw,'canny');%��canny����ʶ��ǿ��ͼ���еı߽�
figure,imshow(grd);title('ͼ���Ե��ȡ');%���ͼ���Ե
bg1=imclose(bw,strel('rectangle',[rectangle_x,rectangle_y]));%������
figure,imshow(bg1);title(['ͼ�������[',num2str(rectangle_x),',',num2str(rectangle_y),']']);%����������ͼ��
%%
%========================��ͨ����===============
%�Զ�ֵͼ�����������ȡ���������������������������������������Ƚϣ���ȡ��������
[L,num] = bwlabel(bg1,8);%��ע������ͼ���������ӵĲ��֣�LΪ��ͨ�������numΪ��ͨ������Ŀ��
Feastats = regionprops(L,'basic');%����ͼ�������ϵ�������ߴ磨'Area'�Ǳ������������ͼ����������������ܸ�����'BoundingBox'��1��ndims(L)*2�е���������������Ӧ�������С���Ρ�BoundingBox ��ʽΪ [ul_corner width]������ ul_corner �� [x y z ...] ��������ʽ�����߽���ӵ����Ͻǡ�boxwidth �� [x_width y_width ...] ��ʽָ���߽��������ÿ��ά������ĳ��ȡ���
                                  %'Centroid'��1��ndims(L)�е�����������ÿ����������ģ����ģ���
Area=[Feastats.Area];%�������
BoundingBox=[Feastats.BoundingBox];%[x y width height]���ƵĿ�ܴ�С
RGB_image2= label2rgb(L, 'spring', 'k', 'noshuffle'); %��־ͼ����RGBͼ��ת��
figure,imshow(RGB_image2);title('ͼ���ɫ���');%�����ܵĲ�ɫͼ��
%%
%======================ͼ���и�=================
%����ɸѡ�����ͨ����ĳ���ȣ���������������
if num~=1
l=0;
startcol=zeros(1,num);
startrow=zeros(1,num);
width=zeros(1,num);
hight=zeros(1,num);
for k= 1:num
    l=l+1;   
    startcol(k)=BoundingBox((l-1)*4+1)-supplement_x;%��ͨ�������Ͻ�����x
    startrow(k)=BoundingBox((l-1)*4+2)-supplement_y;%��ͨ�������Ͻ�����y
    if startcol(k)<0||startrow(k)<0
        l=l-1;
        continue

    end
    width(k)=BoundingBox((l-1)*4+3)+supplement_x;%��
    hight(k)=BoundingBox((l-1)*4+4)+supplement_y;%��
    if width(k)<rectangle_width(1)||width(k)>rectangle_width(2)|| hight(k)<rectangle_hight(1) || hight(k)>rectangle_hight(2)%��ܵĿ�Ⱥ͸߶ȵķ�Χ
        l=l-1;
        continue
    end
    rato=width(k)/hight(k);%���㳵�Ƴ����
    if rato>pr_rato(1) && rato<pr_rato(2)   
        break;
    end
end
    endrow=startrow(l)+hight(l)+supplement_y;
    endcol=startcol(l)+width(l)+supplement_x;
else
    l=1;
    startcol=BoundingBox((l-1)*4+1)-supplement_x;%��ͨ�������Ͻ�����x
    startrow=BoundingBox((l-1)*4+2)-supplement_y;%��ͨ�������Ͻ�����y
    width=BoundingBox((l-1)*4+3)+supplement_x;%��
    hight=BoundingBox((l-1)*4+4)+supplement_y;%��
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
rgb_sub1=rgb_image(startrow(l):endrow,startcol(l):endcol,:);%ȡ��ͼ��ͼ
gray1=rgb2gray(rgb_sub1);
sbw1=im2bw(rgb_sub1);%��ȡ���ƶ�ֵ��ͼ
grd1=edge(sbw1,'canny');%��ȡ���Ʊ߽���ͼ


figure,subplot(3,1,1),imshow(rgb_sub1);title('ֽ����ͼ');%��ʾֽ�ҵĶ�ֵͼ
subplot(3,1,2),imshow(sbw1);title('ֽ�Ҷ�ֵ��ͼ');%��ʾֽ�ҵĶ�ֵͼ
subplot(3,1,3),imshow(grd1);title('ֽ�ұ߽���ͼ');%��ʾֽ�ҵı߽�
%%
%===========================ͼ��ʶ��============
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
%======����ʶ�����ݱ����
for i=1:4
    R_count_list(i,count)=sum(R(:,sub_width_line(i)));%һ��Ϊ13�е�һ��
    G_count_list(i,count)=sum(G(:,sub_width_line(i)));%һ��Ϊ4�е�һ��
    B_count_list(i,count)=sum(B(:,sub_width_line(i)));
end
for i=1:2
    R_count2_list(i,count)=sum(R(sub_height_line(i),:));%һ��Ϊ13�е�һ��
    G_count2_list(i,count)=sum(G(sub_height_line(i),:));%һ��Ϊ2�е�һ��
    B_count2_list(i,count)=sum(B(sub_height_line(i),:));
end
%======��������==========
close all%�������
save RGB_list R_count_list G_count_list B_count_list R_count2_list G_count2_list B_count2_list %��������
end
%%

% liccode=char(['0':'13']); %�����Զ�ʶ���ַ������  
% length_code=length(liccode);
% add_rgb=zeros(1,13);
% for k=1:13
%     add_rgb(k)=0;
%     for i=1:4
%     add_rgb(k)=add_rgb+abs(R_count_list(i,k)-R_count(i));
%     add_rgb(k)=add_rgb+abs(G_count_list(i,k)-G_count(i));
%     add_rgb(k)=add_rgb+abs(B_count_list(i,k)-B_count(i));
%     end
%     for i=1:2
%     add_rgb(k)=add_rgb+abs(R_count2_list(i,k)-R_count2(i));
%     add_rgb(k)=add_rgb+abs(G_count2_list(i,k)-G_count2(i));
%     add_rgb(k)=add_rgb+abs(B_count2_list(i,k)-B_count2(i));
%     end
% end
% [~,findc]=min(add_rgb)%�����Сֵλ��