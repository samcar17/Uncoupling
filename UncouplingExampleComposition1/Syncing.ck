//This is the main composition file!
//Most of this is setup
Shred unsporkSine;
10000 => int speed2;
Gain g => dac;
SinOsc s => JCRev SineRev => Chorus SineChs => ADSR sadSr => LPF SineLPF => Gain SineGain => g;
//Setting up gains - they will get connected to Uncoupling a bit later
Gain kickGain => g;
Gain gretchGain => HPF parlatoFilter => LPF lowParlatoFilter => g;
Gain hatGain => LPF hatLPF => HPF hatHPF => Pan2 hatPan => g;
Gain OHatGain => LPF OHatLPF => HPF OHatHPF => JCRev OHatVerb => Pan2 OHatPan => g;
Gain clapGain => LPF clapLPF => HPF clapHPF => PRCRev clapVerb => g;
Gain deptGain => LPF deptLPF => HPF deptHPF => JCRev deptVerb => g;
Gain snareGain => LPF snareLPF => JCRev snareVerb => g; 
Gain cbGain => LPF cbLPF => Pan2 cbPan => g;
Gain conga1Gain => Pan2 congPan => g; 
Gain conga2Gain => Pan2 congPan2 => g; 
//Setting Gains, Pans, Filters, Verbs etc...
0.25 => congPan.pan;
-0.25 => congPan2.pan;
0.25 => hatPan.pan;
-0.25 => OHatPan.pan;
0.1 => conga1Gain.gain; 
0.1 => conga2Gain.gain;
0.1 => cbGain.gain;
2000 => snareLPF.freq;
2000 => cbLPF.freq;
0.00001 => snareVerb.mix;
10000 => deptLPF.freq;
500 => deptHPF.freq;
0.1 => deptVerb.mix;
0.9 => SineChs.modDepth;
0.1 => SineChs.mix;
0.1 => SineRev.mix;
1500 => SineLPF.freq;
0.0 => SineGain.gain;
200 => parlatoFilter.freq;
6000 => lowParlatoFilter.freq;
5000 => clapLPF.freq;
200 => clapHPF.freq;
5000 => hatLPF.freq;
4000 => hatHPF.freq;
3500 => OHatHPF.freq;
5500 => OHatLPF.freq;
0.2 => gretchGain.gain;
0.9 => g.gain;
0.5 => kickGain.gain;
0.3 => hatGain.gain;
0.15 => OHatGain.gain;
0.15 => clapGain.gain;
0.005 => clapVerb.mix;
0.01 => OHatVerb.mix;
0.7 => deptGain.gain;
0.07 => snareGain.gain;

//Arrays for timing. The neat thing about Uncoupling is that they can all run at different speeds, which makes polymetrical subdividions really easy
//E.g. hatArray is running a double-speed 10 against the kick's 8 - which would sound like subdiving the kick's bar into 5
[1.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0] @=> float array[];
[1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0] @=> float kickArray[];
[2.0, 1.5, 0.0, 2.0, 0.0, 2.0, 1.5, 0.0, 2.0, 0.0] @=> float hatArray[];
[0.0, 0.0, 0.0, 0.0, 1.15, 0.0, 0.0, 0.0] @=> float OHatArray[];
[0.0, 0.0, 0.0, 0.0, 0.9, 0.0, 0.0, 0.0] @=> float clapArray[];
[1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0] @=> float snareArray[];
[3., 0.0, 3., 0.0, 0.0, 0.0, 0.0, 3., 0.0, 3., 0.0, 0.0, 0.0, 3., 3., 3.] @=> float conga1Array[];
[0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0] @=> float conga2Array[];
[0.0, 1.5, 0.0, 0.0] @=> float deptArray[];
[0, 42, 42, 0] @=> int SineArray[];
[42, 0, 42, 42] @=> int SineFill[];
[0, 35, 35, 0] @=> int SineArray2[];
[35, 0, 35, 35] @=> int SineFill2[];

//Variables for looping and polyrhythms
16 => int loopLength;
0 => int L1;
speed2/1.25 $ int => int speed5;

//Creating a whole bunch of Uncoupling objects
//This could have been done in an array, however I like the visual aspect of being able to see everything for reference further down and I feel like implimenting 
//them in an array would have made that less clear
Uncoupling uncouple;
Uncoupling uncouple2;
Uncoupling uncouple3;
Uncoupling uncouple4;
Uncoupling uncouple5;
Uncoupling uncouple6;
Uncoupling uncouple7;
Uncoupling uncouple8;
Uncoupling uncouple9;
Uncoupling uncouple10;
Uncoupling finalBreath;
//Loading samples into Uncoupling objects
uncouple.loadSample("/samples/Begin.wav");
uncouple2.loadSample("/samples/BD_Blofeld_005.wav");
uncouple3.loadSample("/samples/hh_01.wav");
uncouple4.loadSample("/samples/hh_02.wav");
uncouple5.loadSample("/samples/clap_02.wav");
uncouple6.loadSample("/samples/parlato rough cut.wav");
uncouple7.loadSample("/samples/MR16_Cow_T1A.wav");
uncouple8.loadSample("/samples/BD_Blofeld_005.wav"); 
uncouple9.loadSample("/samples/BD_Blofeld_005.wav"); 
uncouple10.loadSample("/samples/MR16_Cow_T1A.wav");
finalBreath.loadSample("/samples/Begin.wav");
//Patching objects
uncouple.connect(s, gretchGain, 1, 1);
uncouple2.connect(s, kickGain, 0, 1);
uncouple3.connect(s, hatGain, 0, 1);
uncouple4.connect(s, OHatGain, 0, 1);
uncouple5.connect(s, clapGain, 0, 1);
uncouple6.connect(s, deptGain, 0, 1);
uncouple7.connect(s, snareGain, 0, 1);
uncouple8.connect(s, conga1Gain, 0, 1);
uncouple9.connect(s, conga2Gain, 0, 1);
uncouple10.connect(s, cbGain, 0, 1);

//begin piece by grabbing a loop of one sample being cut up by the rhythmic function
uncouple.sporkRhythmic(array, speed2, 0, 426636, 0); 
uncouple.sporkLoop(1, speed2, loopLength);
(speed2*loopLength)::samp => now;
uncouple.unsporkRhythmic();//unspork rhythmic function so it doesn't muddle our loop and then gradually add other samples
uncouple2.sporkRhythmic(kickArray, speed2, 0, 0, 0);
(speed2*(loopLength*2))::samp => now;
uncouple3.sporkRhythmic(hatArray, ((speed5/2)), 0, 0, 0);
(speed2*(loopLength*2))::samp => now;
uncouple4.sporkRhythmic(OHatArray, (speed2/4), 0, 10960, 0);
(speed2*(loopLength*2))::samp => now;
uncouple5.sporkRhythmic(clapArray, speed2, 0, 0, 0);
(speed2*(loopLength*2))::samp => now;
uncouple6.sporkEquals(deptArray,(speed2*4), 0, 76828); 
uncouple7.sporkRhythmic(snareArray, (speed2/2), 0, 0, 0);
(speed2*(loopLength*2))::samp => now;
uncouple8.sporkRhythmic(conga1Array, (speed2/2), 0, 0, 0);
uncouple9.sporkRhythmic(conga2Array, (speed2/2), 0, 0, 0);
//Add bass
while(L1 < 2){                                                          
    spork~ playSine((speed2/2), SineArray, SineFill) @=> unsporkSine;
    (speed2*(loopLength*2))::samp => now;
    unsporkSine.exit();
    spork~ playSine((speed2/2), SineArray2, SineFill2) @=> unsporkSine;
    (speed2*(loopLength*2))::samp => now;
    unsporkSine.exit();
    L1++;
}

//Drop (as in /remove/) bass, second sample, kick and polyrhythm hi-hat
uncouple6.unsporkEquals();
uncouple2.unsporkRhythmic();
uncouple3.unsporkRhythmic();
(speed2*(loopLength*4))::samp => now;

//Add bass again
while(L1 < 4){
    spork~ playSine((speed2/2), SineArray, SineFill) @=> unsporkSine;
    (speed2*(loopLength*2))::samp => now;
    unsporkSine.exit();
    spork~ playSine((speed2/2), SineArray2, SineFill2) @=> unsporkSine;
    uncouple10.sporkOneShot(0, (speed2/2), 25, 1.3); //add higher cowbell just on second note
    Std.rand2f(-1.0, 1.0) => cbPan.pan;//have it come from a different direction each time
    (speed2*(loopLength*2))::samp => now;
    unsporkSine.exit();
    uncouple10.unsporkOneShot();
    L1++;
}
//Drop main sample and bass, add back kick, second sample and hi-hat
gretchGain =< parlatoFilter;//This is here so we can mute the sound but keep the loop
uncouple6.sporkEquals(deptArray,(speed2*4), 0, 76828);
uncouple2.sporkRhythmic(kickArray, speed2, 0, 0, 0);
uncouple3.sporkRhythmic(hatArray, ((speed5/2)), 0, 0, 0);
(speed2*(loopLength*4))::samp => now;
//Add back bass and main sample
gretchGain => parlatoFilter;
while(L1 < 8){
    spork~ playSine((speed2/2), SineArray, SineFill) @=> unsporkSine;
    (speed2*(loopLength*2))::samp => now;
    unsporkSine.exit();
    spork~ playSine((speed2/2), SineArray2, SineFill2) @=> unsporkSine;
    uncouple10.sporkOneShot(0, (speed2/2), 25, 1.3);
    Std.rand2f(-1.0, 1.0) => cbPan.pan;
    (speed2*(loopLength*2))::samp => now;
    unsporkSine.exit();
    uncouple10.unsporkOneShot();
    L1++;
}
//Keep high cowbell going remove a few things
uncouple10.sporkOneShot(0, (speed2/2), 25, 1.3);
0 => cbPan.pan;
uncouple4.unsporkRhythmic();
uncouple8.unsporkRhythmic();
uncouple9.unsporkRhythmic();
(speed2*(loopLength*4))::samp => now;

//remove all but polyrhythm hat, clap and seconds sample
gretchGain =< parlatoFilter; //should be <uncouple.unsporkLoop();>, however unsporking the loop function still needs debugging, unfortunately (despite all other unspork functions working!(?)). 
uncouple10.unsporkOneShot(); //This is gonna get fixed over the next few days, but for this assignment this function is not "essential" 
uncouple7.unsporkRhythmic();//and disconnecting the gain from the filter is an easy hack to get the same results
uncouple2.unsporkRhythmic();
(speed2*(loopLength*4))::samp => now;
1::second => now; //wait 1 second

//Reconnect stuff, remove everything left and play the original sample that our main loop came from
finalBreath.connect(s, deptGain, 0, 0);
deptGain =< deptLPF;
deptGain.gain(0.05);
deptGain => parlatoFilter;
uncouple3.unsporkRhythmic();
uncouple5.unsporkRhythmic();
uncouple6.unsporkEquals();
finalBreath.sporkOneShot(0, 426636, 0, 1);
426636::samp => now;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~pure FUNk from here down
//takes UGen inputs and disconnects them - reconnecting them through the effect. 
fun static void fold(UGen sigIn, UGen sigOut, float thresh) 
{
    sigIn =< sigOut;
    thresh => float n; //folding point. 
    sigIn => Gain In => blackhole;
    Impulse Out => sigOut; //Remakes signal through 1 sample impulses
    while(true){
            if(In.last() > n) 
        {   //if the signal is above the threshold, minus the threshold off of it, times it by -1 and add the threshold back to it. Chuck it to impulse level.
            (In.last() - n)*(-1) + n => Out.next;
        }
        
        if(In.last() < -n)
        {   //same as before, but the inverse
            (In.last() - n)*(-1) - n => Out.next;
        }
            1::samp => now;
            
        }
}

//Quite a particular function to this piece, but plays through sine array (switiching for a fill occasionally).
//Also sporks folding function and runs sine wave through it to get that chrunchy bass. 
//(For more hot tips on crunchy bass, visit http://bit.ly/2fl1GVV.)
fun void playSine(int rate, int array[], int fill[])
{
    0 => int iter8;
    0.2 => SineGain.gain;
    spork~ fold(s, SineRev, 0.2);
    sadSr.set(10::samp, 2000::samp, 0.4, (rate-4000)::samp); 
    while(true)
    {
        if(iter8%4 == 1)
        {
            for(0 => int i; i < array.cap(); i++)
            {
                fill[i] => Std.mtof => s.freq;
                sadSr.keyOn();
                2010::samp => now;
                sadSr.keyOff();
                (rate-2010)::samp => now;
            }
        }
        else
        {
            for(0 => int i; i < array.cap(); i++)
            {
                array[i] => Std.mtof => s.freq;
                sadSr.keyOn();
                2010::samp => now;
                sadSr.keyOff();
                (rate-2010)::samp => now;
            }
        }
    iter8++;
    }
}
