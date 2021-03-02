 %% Design and Golden Model output images comparison 
 for k = 1:1:10
     outname = sprintf('hdl_design_watermarked_image(result)_%d.txt',k);
     grayImage = uint8(importdata(outname));
     size_file =sprintf('primary_image_%d.txt',k);
     f = fopen(size_file,'r');
     ImageSize = fscanf(f,'%d\n');
     ImageSize =ImageSize(1);
     res = reshape(grayImage,ImageSize,ImageSize);
     GoldenModel_image_name = sprintf('watermarked_image(result)_%d.jpg',k);
     GoldenModel_Image = imread(GoldenModel_image_name);
     figure;
     sgtitle(['Watermarked Image ' num2str(k) ' Comparsion'])
     subplot(1,2,1)
     imshow(GoldenModel_Image);
     title('Golden Model ')
     subplot(1,2,2)
     imshow(res);
     title('Design')
 end