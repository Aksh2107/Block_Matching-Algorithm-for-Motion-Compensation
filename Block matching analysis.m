
%% a simple single level block matcher
clear
close all
clear all

%%%%%%%%%%%%%%% parameters etc %%%%%%%%%%%%%%%%%%%%%%%%

filename    = './qonly.360x288.y';
hres        = 360;  % horizontal size
vres        = 288;  % versical size
B           = 16;    % block size
w           = 4;   % window search range is +/-w 
mae_t       = 4;    % motion threshold MAE per block
start_frame = 1;    
nframes     = 30;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%open the file for reading
fin = fopen(filename,'rb');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% x,y coordimates of the block centres
x = (B/2):B:hres-(B/2); 
y = (B/2):B:vres-(B/2); 

fprintf('processing the sequence\n')
%for i = 1:B_number 
 %   fprintf(sprintf('block number %03d/%03d\n', i, B_number))
for frame = start_frame:start_frame+nframes-1

    fprintf(sprintf('frame %03d/%03d\n', frame, nframes))

    fseek(fin,hres*vres*(frame-1),'bof');
    past_frame = double(fread(fin,[hres vres],'uint8')');
    
    fseek(fin,hres*vres*frame,'bof');
    curr_frame = double(fread(fin,[hres vres],'uint8')');
    
    non_mc_dfd = abs(curr_frame-past_frame); 
   
    non_mc_val = mae(past_frame,curr_frame);
    non_mc_mae(frame) = mean(non_mc_val(:));
    

    figure; image(curr_frame-past_frame+128); colormap(gray(256));
    title('Non motion compensated Frame Difference');
    drawnow;

   % [bdx, bdy, dfd] = blockmatching(curr_frame, past_frame, B(i), w, mae_t);
    [bdx, bdy, dfd] = blockmatching(curr_frame, past_frame, B, w, mae_t);
    
    figure; image((1:hres),(1:vres),curr_frame);colormap(gray(256)); axis image; 
    hold on; title('Motion vectors for each block superimposed on current frame');
    h = quiver(x, y, bdx, bdy, 0, 'b-');
    set(h,'linewidth',1.5); 
    xlabel('Columns'); ylabel('Rows'); hold off;drawnow;
     
    figure; image(dfd + 128); colormap(gray(256));
    mae_mc_dfd = mae(dfd);
   % mc_mae(i,frame) = mean(mae_mc_dfd(:));
    mc_mae(frame) = mean(mae_mc_dfd(:));
end %end of current frame
%end
fclose(fin);
%figure; plot(d)
figure;plot(non_mc_mae, '-+');
hold on;
plot(mc_mae,'-*');
legend('Non-mc','mc');
title('Motion estimation and non motion estimation');



