function display_3(q_img,netvlat_img,maqbool_img)

fig1 = figure;
pos_fig1 = [0 0 1500 320];
set(fig1,'Position',pos_fig1)

qq_img = imread(q_img);

p_margin = 0.002;
subplot_tight(2, 7, [1 2 8 9], p_margin);
imshow(qq_img); %
ntitle(['xlabel ',strcat('NetVLAD Top ','Query Image'],...
    'location','south',...
    'FontSize',10,...
    'backgroundcolor','w');
for j = 1:5
    netvlad = imread(netvlat_img(j,1));
    if(netvlat_img(j,2) == 1)
        image_n = addborder(netvlad, 10, [0,255,0], 'outer'); 
    else
        image_n = addborder(netvlad, 10, [255,0,0], 'outer'); 
    end
    subplot_tight(2, 7, j+2, p_margin);
    imshow(image_n);
    
    ntitle(['xlabel ',strcat('NetVLAD Top ',num2str(j-2))],...
    'location','south',...
    'FontSize',10,...
    'backgroundcolor','w');
    
    maqbool = imread(netvlat_img(j,1));
    if(netvlat_img(j,2) == 1)
        image_m = addborder(maqbool, 10, [0,255,0], 'outer'); 
    else
        image_m = addborder(maqbool, 10, [255,0,0], 'outer'); 
    end
    subplot_tight(2, 7, j+2, p_margin);
    imshow(image_m);
    
    ntitle(['xlabel ',strcat('MAQBOOL Top ',num2str(j-2))],...
    'location','south',...
    'FontSize',10,...
    'backgroundcolor','w');
 
end

    
%X2 = imread('peppers.png'); 
%image = addborder(X2, 10, [255,0,0], 'outer'); 

% 
% 
% subplot_tight(2, 7, 3, p_margin);
% imshow(image); %title ({'2'}); 
% subplot_tight(2, 7, 4, p_margin);
% imshow(image); %title ({'3'}); 
% subplot_tight(2, 7, 5, p_margin);
% imshow(image);% title ({'4'}); 
% subplot_tight(2, 7, 6, p_margin);
% imshow(image); %title ({'5'});
% subplot_tight(2, 7, 7, p_margin);
% imshow(image); %title ({'1'}); 

% subplot_tight(2, 7, 10, p_margin);
% imshow(image); %title ({'8'});
% subplot_tight(2, 7, 11, p_margin);
% imshow(image);% title ({'9'});
% subplot_tight(2, 7, 12, p_margin);
% imshow(image); %title ({'10'});
% subplot_tight(2, 7, 13, p_margin);
% imshow(image); %title ({'6'});
% subplot_tight(2, 7, 14,p_margin);
% imshow(image);% title ({'7'});



ntitle(['xlabel ',num2str(2)],...
    'location','south',...
    'FontSize',10,...
    'backgroundcolor','w');
ntitle(['xlabel ',num2str(2)],...
    'location','south',...
    'FontSize',7);


end

%     if show_output == 3
            % 
            %             subplot(2,6,1); imshow(imread(char(qimg_path))); %q_img
            %             db_imgo1 = strcat(dataset_path,'/images/', db.dbImageFns{ids(1,1),1});  
            %             db_imgo2 = strcat(dataset_path,'/images/', db.dbImageFns{ids(2,1),1});  
            %             db_imgo3 = strcat(dataset_path,'/images/', db.dbImageFns{ids(3,1),1});  
            %             db_imgo4 = strcat(dataset_path,'/images/', db.dbImageFns{ids(4,1),1});  
            %             db_imgo5 = strcat(dataset_path,'/images/', db.dbImageFns{ids(5,1),1});  
            %             db_img1 = strcat(dataset_path,'/images/', db.dbImageFns{idss(1,1),1});  
            %             db_img2 = strcat(dataset_path,'/images/', db.dbImageFns{idss(2,1),1});  
            %             db_img3 = strcat(dataset_path,'/images/', db.dbImageFns{idss(3,1),1});
            %             db_img4 = strcat(dataset_path,'/images/', db.dbImageFns{idss(4,1),1});
            %             db_img5 = strcat(dataset_path,'/images/', db.dbImageFns{idss(5,1),1});
            % 
            %             subplot(2,6,2); imshow(imread(char(db_imgo1))); %
            %             aa = strcat(string(ds_pre(1,1)));title(aa)
            % 
            %             subplot(2,6,3); imshow(imread(char(db_imgo2))); %
            %             aa = strcat(string(ds_pre(2,1)));title(aa)
            % 
            %             subplot(2,6,4); imshow(imread(char(db_imgo3))); %
            %             aa = strcat(string(ds_pre(3,1)));title(aa)
            % 
            %             subplot(2,6,5); imshow(imread(char(db_imgo4))); %
            %             aa = strcat(string(ds_pre(4,1)));title(aa)
            % 
            %             subplot(2,6,6); imshow(imread(char(db_imgo5))); %
            %             aa = strcat(string(ds_pre(5,1)));title(aa)
            % 
            % 
            %             subplot(2,6,8); imshow(imread(char(db_img1))); %
            %             aa = strcat(string(ds_new_top(1,1)), '->', string(prob_q_db(1,1)));title(aa)
            %             subplot(2,6,9); imshow(imread(char(db_img2))); %
            %             aa = strcat(string(ds_new_top(2,1)), '->', string(prob_q_db(1,1)));title(aa)
            %             subplot(2,6,10); imshow(imread(char(db_img3))); %
            %             aa = strcat(string(ds_new_top(3,1)), '->', string(prob_q_db(1,1)));title(aa)
            %             subplot(2,6,11); imshow(imread(char(db_img4))); %
            %             aa = strcat(string(ds_new_top(4,1)), '->', string(prob_q_db(1,1)));title(aa)
            %             subplot(2,6,12); imshow(imread(char(db_img5))); %
            %             aa = strcat(string(ds_new_top(5,1)), '->', string(prob_q_db(1,1)));title(aa)
            % 
            %             %fprintf( '==>> %f %f %f %f %f \n',c_i(1,1), c_i(2,1),c_i(3,1), c_i(4,1) ,c_i(5,1));
            % 
            %      end