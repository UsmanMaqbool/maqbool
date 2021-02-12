function print_level_wsd(data_name,d_type)
    
    [d_folder, d_name, d_ext]= fileparts(data_name);
    
    if d_type == 1
        fprintf( '%s%s file not found.\n', d_name,d_ext);
        fprintf( 'Please download %s%s from <a href="https://usmanmaqbool.github.io/why-so-deep#download-pre-computed-files">project website</a>, \nand extract in %s/.\n', d_name, d_ext, d_folder);
    elseif d_type == 2
        fprintf( 'FeatFn files not found.\n');
        fprintf( 'Please download %s%s from <a href="https://usmanmaqbool.github.io/why-so-deep#download-pre-computed-files">project website</a>->[dbFeatFn, qFeatFn], \nand extract in %s/.\n', d_name, d_ext, d_folder);
    elseif d_type == 3
        fprintf( 'Pre-computed files not found.\n');
        fprintf( 'Please download %s%s_m.zip from <a href="https://usmanmaqbool.github.io/why-so-deep#download-pre-computed-files">project website</a>->[data_test], \nand extract in %s/.\n', d_name, d_ext, d_folder);
    elseif d_type == 4
        fprintf( 'Pre-computed files not found.\n');
        fprintf( 'Please download %s%s.zip from <a href="https://usmanmaqbool.github.io/why-so-deep#download-pre-computed-files">project website</a>->[MAQBOOL], \nand extract in %s/.\n', d_name, d_ext, d_folder);
    end
    fprintf( 'and run again. Otherwise, system will start computing... \n');
    disp('Press any key to continue !') 
    pause;
end