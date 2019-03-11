function M170(subject)
HideCursor;
ioObj = io64;
status = io64(ioObj);
address = hex2dec('378');
data_out=0;
io64(ioObj,address,data_out);

Screen('Preference', 'SkipSyncTests', 1);
QuitKey = KbName('q');
SKey = KbName('s');
RespondKey = KbName('1!');
AssertOpenGL;
screenNumber=max(Screen('Screens'));
gray=GrayIndex(screenNumber); % returns as default the mean gray value of screen
backgroundcolor = gray;

[w, wRect]=Screen('OpenWindow',screenNumber,gray,[0 0 800 600]);


fix=fixation(15,backgroundcolor,0);
ftex=Screen('MakeTexture', w,fix);

condnames ={'gc','cf','gf','ff'};
markers =1:4;

for j=1:43
    imdata=imread(sprintf('C:/data/psychotest/stimulis/cars/gc%d.bmp',j));
    ptex(j)=Screen('MakeTexture', w,imdata);
end
for j=1:43
    imdata=imread(sprintf('C:/data/psychotest/stimulis/cars/cf%d.bmp',j));
    ptex(j+43)=Screen('MakeTexture', w,imdata);
end

for j=1:43
    imdata=imread(sprintf('C:/data/psychotest/stimulis/faces/gf%d.bmp',j));
    ptex(j+86)=Screen('MakeTexture', w,imdata);
end

for j=1:43
    imdata=imread(sprintf('C:/data/psychotest/stimulis/faces/ff%d.bmp',j));
    ptex(j+129)=Screen('MakeTexture', w,imdata);
end
for j=1:41
    imdata=imread(sprintf('C:/data/psychotest/stimulis/cartoons/%d.png',j));
    ptex(j+172)=Screen('MakeTexture', w,imdata);
end
% for i =1:length(condnames)
%     for j=1:6
%         imdata=imread(sprintf('C:/data/psychotest/stimulis/%s%d.png',condnames{i},j));
%         ptex(i,j)=Screen('MakeTexture', w,imdata);
%     end
% end

Screen('TextFont',w, 'Courier New');
Screen('TextSize',w, 25);
Screen('TextStyle', w, 1+2);

for blo=1:2
    DrawFormattedText(w,'Please Have a Rest', 'center','center', 255);
    Screen('Flip',w);

    while 1
        [keyIsDown, secs, keyCode] = KbCheck();
        if keyCode(SKey)
            break;
        elseif keyCode(QuitKey)
            sca;
            return
        end
    end
    
    porder = Shuffle([1:172 1:172 173:213]);
    
    for i=1:length(porder)
        Screen('DrawTexture', w, ftex);
        vbl = Screen('Flip', w);
        %imdata=imread(sprintf('C:/data/psychotest/stimulis/%04d.png',porder(i)));
        %ptex=Screen('MakeTexture', w,imdata);
        Screen('DrawTexture', w, ptex(porder(i)));
        marker = floor((porder(i)-1)/43)+1;
        vbl = Screen('Flip', w, vbl +rand()*0.2+0.2);
        %% set Maker here
         io64(ioObj,address,marker);
       
        
        if porder(i)>172
            while GetSecs() - vbl < 2
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyCode(RespondKey)
                    response(i) = 1;
                    break;
                elseif keyCode(QuitKey)
                    sca;
                    return
                end

          end
        else
            while GetSecs() - vbl < 0.5
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyCode(RespondKey)
                    response(i) = 1;
                    break;
                elseif keyCode(QuitKey)
                    sca;
                    return
                end
            end
            WaitSecs(vbl+0.5 -GetSecs());
        end
        io64(ioObj,address,0);
        
        if rem(i,193)==0
            Screen('DrawTexture', w, ftex);
            vbl = Screen('Flip', w);
            DrawFormattedText(w,'Please Have a Rest', 'center','center', 255);
            Screen('Flip',w);
            while 1
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyCode(RespondKey)
                    break;
                elseif keyCode(QuitKey)
                    sca;
                    return
                end
            end
            
            Screen('DrawTexture', w, ftex);
            Screen('Flip', w);
            while 1
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyCode(SKey)
                    break;
                elseif keyCode(QuitKey)
                    sca;
                    return
                end
            end
        end
    end
    save([subject '_' num2str(blo)],'porder');
end
sca
return
ShowCursor;
