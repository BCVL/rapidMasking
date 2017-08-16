% This is a template for a rapid-presentation
% psychophysics experiment followed by a masking
% stimulus. Erase this text with something specific to your project.

% Started XX/XX/201X
% Current XX/XX/201X
% <<Current author name>>

% Based on rapidMaskingTemplate.m
% Michelle Greene
% August 2017

% Basic housekeeping and set-up
clear Screen; % this is important for saving memory
clear all;
close all;
rand('twister',sum(100*clock)); % seed random number generator

% Get variable input from participant
prompt={'Subject number: ','Initials: '}; % Add more variables as necessary
def={'1','xxx'}; % These show the default values in the pop-up window
title='Input variables';
lineNo=1;
userinput=inputdlg(prompt,title,lineNo,def,'on');

% Interpret input typed in dialog box
subNum=str2num(userinput{1,1}); % note: for numerical input
sinit=userinput{2,1}; % for string input (default)
% etc. continue below until all variables have been initialized

% fill in major hard-coded parameters (these can be in dialog, or not)
presentationTime = % choose presentation time (in s)
maskDuration = % choose time for mask to be on screen (in s)
practiceTrials = % how many pracice trials will you run?
experimentalTrials = % how many experimental trials?
numBlocks = % how many experimental blocks?

% Need to define where stimuli are
sceneDirectory = [pwd,filesep,'%%fill this in!'];
practiceDirectory = %fill in as above. Always good to have a separate ...
% directory of images for practice
maskDirectory = %fill this in as above
sceneList = dir([sceneDirectory, filesep, '*.jpg']); % creates struct of all images
maskList = % fill this in similarly
practiceList = % also fill this in

% Set up displays
window = OpenMainScreen; % see function at bottom
stimRect = CenterRect([0 0 XXX XXX],window.screenRect); % fill in image dimensions
Screen('TextFont', window.onScreen, 'Helvetica');
Screen('TextStyle', window.onScreen, 1);
topPriorityLevel = MaxPriority(window.onScreen);
AssertOpenGL;
% This sets a PTB preference to skip some timing tests. A value
% of 0 runs these tests, and a value of 1 inhibits them. This
% should be set to 0 for actual experiments, since it can detect
% timing problems.
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebugLevel', 3);

% Define response keys
% Note: assumes keyboard use with "a" and "l" keys, counterbalanced across
% participants.
KbName('UnifyKeyNames');
if mod(subNum,2)==0;
    keys = [KbName('l')  KbName('a') KbName('ESCAPE')]; % response key assignments
else
    keys = [KbName('a')  KbName('l') KbName('ESCAPE')]; % response key assignments
end

dataFileName = 'xxxxxx.csv'; % fill this in with a sensible name!
if ~exist(dataFileName, 'file')
    % add headers
    fileID = fopen(dataFileName, 'a+');
    fprintf(fileID,'%s \n',['xxx, xxx, xxx, xxx, xxx, '...
        'xxx']); % etc: fill in with all variables to save on each trial
    fclose(fileID);
end
dataFormatString = '%d, %s, %6.3f, %d, %s, %2.4f \n'; % change and append

% Write the experimental instructions
instructionString = ['In this experiment, you will see xxx ',...
    'xxx. Your task is to xxxxxxxxxxx ',...
    'xxxxx \n',...
    'If the images are xxxx, press the "', KbName(keys(1)), '" key. If the ',...
    'images are xxxx, press the "', KbName(keys(2)), '" key. ',...
    'Please respond as quickly and accurately as possible. \n\n'...
    'Press the space bar when you are ready to continue'];
% note: participants don't have to press space bar. Any key but escape
% is fine. However, it keeps things simple and keeps folks from searching
% for the "any key". Don't laugh - it's absolutely happened!

% Note: Up until this point, the participant has not seen anything except
% for the gray screen that opens in the OpenMainScreen function. We need
% to send our instructions to the main screen.
DrawFormattedText(window.onScreen, instructionString, 'center', 'center', [0 0 0], 48);
Screen('Flip', window.onScreen,[],1); % instructions on screen now
FlushEvents('KeyDown');
GetChar; % upon key press, instructions go away
Screen('FillRect',window.onScreen,window.bcolor);
Screen('Flip', window.onScreen); % back to gray screen

message = [' XXX tell participant to press key to start practice'];

DrawFormattedText(window.onScreen, message, 'center', 'center', [0 0 0], 70);
Screen('Flip', window.onScreen);
FlushEvents('KeyDown');
GetChar;
WaitSecs(.3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main experimental loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HideCursor;
Priority(topPriorityLevel); % to ensure the most accurate timing
ListenChar(2);    %  suppress output of keypresses in the command window
% Note: it's good to comment out the previous line when debugging because
% if your program crashes, you will have a "dead" keyboard that you'll need
% to CTRL-C and SCA out of.
clearTextureFlag = 0; % memory management: do we have to clear the background texture?

% start with XX practice trials
for practice = 1:-1:0
    if practice
        blockMessage = 'practice ';
        nTrials = practiceTrials;
        stimDirectory = practiceDirectory;
        thisList = practiceList;
        presTime = .1; % Assumes 100 ms as practice. Change if desired.
    else
        blockMessage = 'experimental ';
        nTrials = experimentalTrials;
        stimDirectory = sceneDirectory;
        thisList = sceneList;
        presTime = presentationTime;
    end
    
    % screen goes blank
    Screen('FillRect',window.onScreen,window.bcolor);
    Screen('Flip',window.onScreen);
    
    % ready, set, go!
    nTrialString = num2str(nTrials);
    message = [' Press any key to begin ', nTrialString, ' ', blockMessage, 'trials'];
    DrawFormattedText(window.onScreen, message, 'center', 'center', [0 0 0], 70);
    Screen('Flip', window.onScreen);
    FlushEvents('KeyDown');
    GetChar;
    WaitSecs(.3);
    
    % randomize the images
    % Note: this assumes that all conditions within a directory are
    % balanced (for example, if task is categorization that there are equal
    % numbers of images in each category). If this is not the case, come
    % talk to me about how to balance the experiment.
    thisList = Shuffle(thisList);
    maskList = Shuffle(maskList);
    
    % determine when to give participant a break
    trialsPerBlock = round(nTrials/nBlocks);
    
    for trial = 1:nTrials
        % give participants a break
        if trial>1 && mod(trial,trialsPerBlock)==0 && trial<nTrials-25
            DrawFormattedText(window.onScreen, 'Break. Press space bar to continue.', 'center', 'center', [0 0 0]);
            Screen('Flip',window.onScreen);
            FlushEvents('KeyDown');
            GetChar;
            WaitSecs(.3);
        end
        
        % load the appropriate image
        imname = thisList(trial).name;
        thisImage = imread([sceneDirectory, filesep, imname]);
        
        % load the mask image
        maskname = %%% fill this in similarly
        thisMask = %% fill this in similarly
        
        %%%%%%%%%%%%%%%%%%%%%
        % Trial sequence
        %%%%%%%%%%%%%%%%%%%%%
        response = 9000; % default value until real response given
        
        % show a fixation point for 200 msec
        Screen('FillRect',window.onScreen,0,[window.centerX-5 window.centerY-5 window.centerX+5 window.centerY+5]); % fixation pt
        Screen('Flip', window.onScreen,[],1);
        WaitSecs(.2);
        
        % screen goes blank
        Screen('FillRect',window.onScreen,window.bcolor);
        Screen('Flip',window.onScreen);
        
        % first, clear any existing textures to save memory
        if clearTextureFlag
            Screen('Close',imageTexture);
            Screen('Close',maskTexture);
        else
            clearTextureFlag = 1;
        end
        
        % show image and then follow with mask
        imageTexture = Screen('MakeTexture', window.onScreen, thisImage);
        maskTexture = Screen('MakeTexture',window.onScreen,thisMask);
        Screen('DrawTexture', window.onScreen, imageTexture,[],stimRect);
        [onTime]=Screen('Flip',window.onScreen);
        WaitSecs(presTime);
        Screen('DrawTexture',window.onScreen, maskTexture);
        [offTime]=Screen('Flip',window.onScreen);
        totalTime=offTime-onTime; % this is a good sanity check and should be saved
        WaitSecs(maskDuration);
        
        % screen goes blank
        Screen('FillRect',window.onScreen,window.bcolor);
        Screen('Flip',window.onScreen);
        
        % get response and reaction time
        t2 = GetSecs; % we start recording reaction time from here
        % wait for and get responses
        while response==9000
            FlushEvents('keyDown');
            [keyIsDown,secs,keyCode]=KbCheck;
            if keyIsDown
                if length(find(keyCode))==1
                    if find(keyCode)==Key1 || find(keyCode)==Key2
                        RT=secs-t2;
                        response=find(keyCode);
                        response=response(1);
                        break;
                    elseif find(keyCode)==KbName('escape')
                        Screen('CloseAll');
                        return;
                    end
                end
            end
        end
        
        % check to see if response is correct and give feedback
        % IMPORTANT NOTE: Up until this point, we have not chosen a task.
        % You will need to check with me about what the participant will be
        % doing and then code each image according to condition (i.e.
        % category, most likely). Here I am including the basic structure
        % that you would follow.
        if myCondition(trial)==1 && response==Key1 % correct myCondition response
            correct = 1; % you will want to store this and RT in file
            feedbackMessage = ['Correct! RT = ', num2str(RT), ' s'];
        elseif myCondition(trial)==1 && response==Key2; % incorrect response
            correct=0;
            feedbackMessage = 'Wrong';
        elseif myCondition(trial)==0 && response==Key1 % incorrect response
            correct=0;
            feedbackMessage = 'Wrong';
        elseif myCondition(trial)==0 && response==Key2;
            correct=1;
            feedbackMessage = ['Correct! RT = ', num2str(RT), ' s'];
        else
            correct=0;
            feedbackMessage = 'Wrong Key!';
        end
        
        % display the feedback for one second
        DrawFormattedText(window.onScreen, feedbackMessage, 'center', 'center');
        Screen('Flip', window.onScreen);
        WaitSecs(1);
        Screen('FillRect',window.onScreen,128);
        Screen('Flip',window.onScreen);
        
        % save the data on each trial
        dataFile = fopen(dataFileName, 'a');
        fprintf(dataFile, dataFormatString, xxx, xxx, xxx, xxx,...
            xxx, xxx, totalxxxTime, xxx, xxx); % fill in based on above
        fclose('all');
        
    end
end

DrawFormattedText(window.onScreen, 'Thanks for participating!', 'center', 'center', [0 0 0]);
Screen('Flip', window.onScreen);
WaitSecs(2);
Screen('CloseAll');

% Close it out
Screen('CloseAll');

function window = openMainScreen

% display requirements (resolution and refresh rate)
window.requiredRes  = [];
window.requiredRefreshrate = [];

%basic drawing and screen variables
window.gray        = 127;
window.black       = 0;
window.white       = 255;
window.fontsize    = 32;
window.bcolor      = window.gray;

%open main screen, get basic information about the main screen
screens=Screen('Screens'); % how many screens attached to this computer?
window.screenNumber=max(screens); % use highest value (usually the external monitor)
window.onScreen=Screen('OpenWindow',window.screenNumber, 0, [], 32, 2); % open main screen
[window.screenX, window.screenY]=Screen('WindowSize', window.onScreen); % check resolution
window.screenDiag = sqrt(window.screenX^2 + window.screenY^2); % diagonal size
window.screenRect  =[0 0 window.screenX window.screenY]; % screen rect
window.centerX = window.screenRect(3)*.5; % center of screen in X direction
window.centerY = window.screenRect(4)*.5; % center of screen in Y direction

% set some screen preferences
[sourceFactorOld, destinationFactorOld]=Screen('BlendFunction', window.onScreen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Preference','VisualDebugLevel', 0);

% get screen rate
[window.frameTime nrValidSamples stddev] =Screen('GetFlipInterval', window.onScreen, 60);
window.monitorRefreshRate=1/window.frameTime;

% paint mainscreen bcolor, show it
Screen('FillRect', window.onScreen, window.bcolor);
Screen('Flip', window.onScreen);
Screen('FillRect', window.onScreen, window.bcolor);
Screen('TextSize', window.onScreen, window.fontsize);
