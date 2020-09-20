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