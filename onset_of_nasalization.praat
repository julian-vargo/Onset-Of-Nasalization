#Onset of Nasalization Detector for Prenasalized Vowels
#Julian Vargo (2024)
#Department of Spanish & Portuguese
#University of California, Berkeley
#Please enter the appropriate file paths into lines 11 and 295

form Onset of Nasalization - Vargo (2024)
	comment Welcome to the Onset of Nasalization Detector Program
    comment " "
	comment How to cite:
	comment Vargo (2024). Onset of Nasalization Detector [Computer Software]
	comment University of California, Berkeley
	comment Department of Spanish and Portuguese
    comment " "
	comment Please enter the file path where your TextGrid and Sound is located
	comment Windows users, enter file paths without quotation marks:    C:\Users\...\folder
	sentence inputFolder C:\Users\julia\Documents\Test_SRT\praat_mass_analyzer
	comment Please insert the desired file path and name of your output .csv file
    comment Windows users, enter file paths without quotation marks:     C:\Users\...\folder\file.csv
	sentence csvName C:\Users\julia\Documents\Test_SRT\Nasalization_Data.csv
	comment Which tier is your phoneme tier? (Note: the script is only compatible with Arpabet).
	integer tierNumber 2
endform

writeInfoLine: "Initializing Onset of Nasalization Detector"
appendInfoLine: newline$, "Vargo, Julian (2024). Onset of Nasalization Detector [Computer Software]"
appendInfoLine: "University of California, Berkeley. Department of Spanish & Portuguese"
appendInfoLine: newline$, "Script is loading. This may take a minute. Please stand by."

#Create initial csv file, open up file list, and calculate the number of TextGrids in the input folder
writeFileLine: csvName$, "phoneme,following_phone,vowel_duration,percentage_nasalized,nasalization_percentile,vowel_start,vowel_end,f1_midpoint,bandwidth_midpoint,adjusted_bandwidth_midpoint,endofform"
fileList = Create Strings as file list: "fileList", inputFolder$ + "\" +"*.TextGrid"
numberOfFiles = Get number of strings

#Start the outmost for loop, where each file is analyzed
for file to numberOfFiles
    selectObject: fileList
    currentFile$ = Get string: file
    currentTextGrid = Read from file: inputFolder$ + "\"+ currentFile$
    currentTextGrid$ = selected$("TextGrid")
    currentSound = Read from file: inputFolder$ + "\"+ (replace$(currentFile$,  ".TextGrid", ".wav", 4))
    currentSound$ = selected$("Sound")
    selectObject: currentTextGrid
    numberOfPhonemes = Get number of intervals: tierNumber
    Convert to Unicode
    select Sound 'currentSound$'
    globalFormant = To Formant (burg)... 0 5 5500 0.025 50
    select Sound 'currentSound$'
    globalPitch = To Pitch... 0 75 600
    intervalNumber = 1
    fileSoundChunkName$ = currentFile$ + "_part"

    #Start the second-layer for loop, where each prenasal vowel interval is scanned for and then analyzed
    for thisInterval from intervalNumber to numberOfPhonemes
        select TextGrid 'currentTextGrid$'
        thisPhoneme$ = Get label of interval: 2, thisInterval
        if thisPhoneme$ = "AA0" or thisPhoneme$ = "AA1" or thisPhoneme$ = "AA2" or thisPhoneme$ = "AE0" or thisPhoneme$ = "AE1" or thisPhoneme$ = "AE2" or thisPhoneme$ = "AH0" or thisPhoneme$ = "AH1" or thisPhoneme$ = "AH2" or thisPhoneme$ = "AO0" or thisPhoneme$ = "AO1" or thisPhoneme$ = "AO2" or thisPhoneme$ = "AW0" or thisPhoneme$ = "AW1" or thisPhoneme$ = "AW2" or thisPhoneme$ = "AY0" or thisPhoneme$ = "AY1" or thisPhoneme$ = "AY2" or thisPhoneme$ = "EH0" or thisPhoneme$ = "EH1" or thisPhoneme$ = "EH2" or thisPhoneme$ = "ER0" or thisPhoneme$ = "ER1" or thisPhoneme$ = "ER2" or thisPhoneme$ = "EY0" or thisPhoneme$ = "EY1" or thisPhoneme$ = "EY2" or thisPhoneme$ = "IH0" or thisPhoneme$ = "IH1" or thisPhoneme$ = "IH2" or thisPhoneme$ = "IY0" or thisPhoneme$ = "IY1" or thisPhoneme$ = "IY2" or thisPhoneme$ = "OW0" or thisPhoneme$ = "OW1" or thisPhoneme$ = "OW2" or thisPhoneme$ = "OY0" or thisPhoneme$ = "OY1" or thisPhoneme$ = "OY2" or thisPhoneme$ = "UH0" or thisPhoneme$ = "UH1" or thisPhoneme$ = "UH2" or thisPhoneme$ = "UW0" or thisPhoneme$ = "UW1" or thisPhoneme$ = "UW2"
            followerNumber = thisInterval + 1
            followingPhoneme$ = "placeholder to create the variable"
            if thisInterval < numberOfPhonemes
                followingPhoneme$ = Get label of interval: 2, followerNumber
                if followingPhoneme$ = "N" or followingPhoneme$ = "M" or followingPhoneme$ = "NG" or followingPhoneme$ = "NX" or followingPhoneme$ = "EN" or followingPhoneme$ = "EM" or followingPhoneme$ = "ENG"

                    thisPhonemeStartTime = Get start point: 2, thisInterval
                    thisPhonemeStartTime$ = fixed$(thisPhonemeStartTime, 4)
                    thisPhonemeEndTime = Get end point: 2, thisInterval
                    thisPhonemeEndTime$ = fixed$(thisPhonemeEndTime, 4)
                    duration = thisPhonemeEndTime - thisPhonemeStartTime
                    duration$ = fixed$(duration, 4)

                    for i from 0 to 20
                        time [i] = thisPhonemeStartTime + (duration * 0.05 * i)
                    endfor

                    for i from 1 to 19
                        selectObject: globalFormant
                        currentTime = time [i]
                        previousTime = time [i-1]
                        nextTime = time [i+1]
                        
                        f1 [i] = Get value at time... 1 currentTime Hertz Linear
                        if f1 [i] = undefined
                            f1 [i] = 99999
                        endif
                        
                        bandwidth [i] = Get bandwidth at time... 1 currentTime Hertz Linear

                        selectObject: globalPitch
                        f0 [i] = Get value at time... currentTime Hertz Linear
                        if f0 [i] = undefined
                            f0 [i] = 99999
                        endif
                        p0_approx = f1 [i] - f0 [i]
                        p1_approx = f1 [i] + f0 [i] 
                        p0_filterLowerBound = p0_approx - f0 [i] / 4
                        p0_filterUpperBound = p0_approx + f0 [i] / 4
                        p1_filterLowerBound = p1_approx - f0 [i] / 4
                        p1_filterUpperBound = p1_approx + f0 [i] / 4
                        a1_filterLowerBound = f1 [i] - f0 [i] / 4
                        a1_filterUpperBound = f1 [i] + f0 [i] / 4
                        a0_filterLowerBound = f0 [i] - f0 [i] / 4
                        a0_filterUpperBound = f0 [i] + f0 [i] / 4
                        segmentDuration = duration * 0.1
                        mockLowerBound = 6.45 / segmentDuration
                        currentf0 = f0 [i]
                        currentf0$ = fixed$(currentf0, 10)
                        p0_filterLowerBound$ = fixed$(p0_filterLowerBound, 10)
                        p0_filterUpperBound$ = fixed$(p0_filterUpperBound, 10)

                        if p0_filterLowerBound$ <> "--undefined--"
                            #This section measures a1
                            selectObject: currentSound
                            currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
                            selectObject: currentSoundChunk
                            currentSoundChunk2 = Filter (pass Hann band)... a1_filterLowerBound a1_filterUpperBound 1
                            currentIntensity = To Intensity... mockLowerBound 0 yes
                            a1 = Get maximum... previousTime nextTime sinc70
                            removeObject: currentSoundChunk
                            removeObject: currentIntensity
                            removeObject: currentSoundChunk2
                            
                            #This section measures p0
                            selectObject: currentSound
                            currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
                            selectObject: currentSoundChunk
                            currentSoundChunk2 = Filter (pass Hann band)... p0_filterLowerBound p0_filterUpperBound 1
                            currentIntensity = To Intensity... mockLowerBound 0 yes
                            p0 = Get maximum... previousTime nextTime sinc70
                            removeObject: currentSoundChunk
                            removeObject: currentSoundChunk2
                            removeObject: currentIntensity

                            #Calculate a1-p0
                            a1p0 [i] = a1 - p0

                            #This section measures standard deviation of the spectrum between 0 and 1000 Hz
                            selectObject: currentSound
                            currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
                            selectObject: currentSoundChunk
                            currentSoundChunk2 = Filter (pass Hann band)... 0 1000 1
                            removeObject: currentSoundChunk
                            selectObject: currentSoundChunk2
                            currentSpectrum = To Spectrum... yes
                            removeObject: currentSoundChunk2
                            selectObject: currentSpectrum
                            std01k [i] = Get standard deviation... 2
                            removeObject: currentSpectrum
                        endif
                    endfor

                    #calculate derivatives of nasal cues
                    for i from 2 to 18
                        if f1 [i] <> undefined or f0 [i] <> undefined
                            derivativeA1p0 [i] = (a1p0 [i+1] - a1p0 [i-1]) / (duration * 0.1)
                            derivativeBandwidth [i] = (bandwidth [i+1] - bandwidth [i-1]) / (duration * 0.1)
                            derivativeStd01k [i] = (std01k [i+1] - std01k [i-1]) / (duration * 0.1)
                        endif
                    endfor

                    #Scan all of the currently stored derivates to find the time at which the maximum rate of spectral change ocurred
                    inflectionPointBandwidth = 0
                    inflectionPointA1p0 = 99999
                    inflectionPointStd01k = 0
                    percentileOfInflectionBandwidth = 0
                    percentileOfInflectionA1p0 = 0
                    percentileOfInflectionStd01k = 0
                    for i from 2 to 18
                        if f1 [i] <> undefined
                            if f0 [i] <> undefined
                                if derivativeBandwidth [i] > inflectionPointBandwidth
                                    inflectionPointBandwidth = derivativeBandwidth [i]
                                    percentileOfInflectionBandwidth = 0.05 * i
                                endif
                                if derivativeA1p0 [i] < inflectionPointA1p0
                                    inflectionPointA1p0 = derivativeA1p0 [i]
                                    percentileOfInflectionA1p0 = 0.05 * i
                                endif
                                if derivativeStd01k [i] > inflectionPointStd01k
                                    inflectionPointStd01k = derivativeStd01k [i]
                                    percentileOfInflectionStd01k = 0.05 * i
                                endif
                            endif
                        endif
                    endfor

                    #Calculate the onset of nasalization by averaging all of the inflection timepoints
                    onsetOfNasalization = (percentileOfInflectionA1p0 + percentileOfInflectionStd01k + percentileOfInflectionBandwidth) / 3
                    onsetOfNasalization$ = fixed$(onsetOfNasalization, 4)
                    percentageNasalized = 1 - onsetOfNasalization
                    percentageNasalized$ = fixed$(percentageNasalized, 4)
                    
                    #Convert F1 and Bandwidth into strings to be displayed on the spreadsheet, for optional statistical analysis
                    f1Midpoint = f1 [10]
                    f1Midpoint$ = fixed$(f1Midpoint, 4)

                    #The filler variable makes sure that the exported spreadsheet displays correctly, so statistical analysis can be done on R
                    fillerVariable$ = "endOfForm"

                    #Write a single row of the spreadsheet
                    appendFileLine: csvName$, thisPhoneme$,",",followingPhoneme$,",",duration$,",",percentageNasalized$,",",onsetOfNasalization$,",",thisPhonemeStartTime$,",",thisPhonemeEndTime$,",",f1Midpoint$,",",fillerVariable$,tab$
                endif
            endif
        endif
    endfor
    removeObject: globalFormant
    removeObject: globalPitch
    removeObject: currentSound
    removeObject: currentTextGrid
endfor
removeObject: fileList
appendInfoLine: newline$, "Script completed successfully"
