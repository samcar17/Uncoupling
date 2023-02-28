//Uncoupling is a class designed mostly around SndBuf with a liiiiitle bit of LiSa thrown in (still experimental atm, but getting better!).
//The purpose of this tool was to create a way of arranging/sequencing/chopping samples that was quick and easy to get interesting results out of.
//Samples are great, but prior to building this, I found them a bit of a pain to impliment in ChucK, and super hard to cut in the way I was used to.
//In building this, I wanted to create a way of cutting samples that seemed idiomatic to ChucK - hence, most of these functions involve a degree of 
//randomness, if not an algorithmic approach. As this can be unmusical at times, I've added a few different ways of controlling the randomness, which 
//yeilded it a lot more versitile than i initially thought it was going to be. It's slowly becoming quite a cool way of livecoding interesting sounding
//sample patternes quickly, and I'm intending to continue developing it over the next few weeks to fix a few bugs, include MIDI support (so it can be edited 
//and performed live with a MIDI controller) and add a few more features. Hopefully by the end I'll have a fairly "all-in-one" livecoding sampler tool.
//(Instant Four Tet/Actress!!)

public class Uncoupling{
    //Setup
    SndBuf Sample;
    LiSa Lisa;
    Gain g;
    ADSR clickKilla;
    0 => int RhythmId;
    0 => int LoopId;
    0 => int oneShotId;
    0 => int EqualsId;
    
    //Loading sample through function so it only takes one line to set this up insteat of 4!
    fun void loadSample(string sampleName)
    {
        me.dir() => string path;
        sampleName => string filename;
        path + filename => filename;
        filename => Sample.read;
        <<<"Number of samples in this sample: " + Sample.samples()>>>;
        if(Sample.samples() == 0)
        {<<<"Missing something? - can't load sample file.">>>;}
    }
    
    //Patching function. ClickKilla is a hardset ADSR that removes impulses from sample cuts. You can get some really pretty impulse rhythms with this 
   //setting off. Selector decides between routing straight out or through LiSa. 
    fun void connect(UGen In, UGen out, int selector, int clickKillaVal)
    {
        if(selector == 0)
        {Sample => out;}
        if(selector == 1)
        {Sample => Lisa => out;
         Sample => g => out;
         g.gain(0.7);}
        if(selector == 0 && clickKillaVal == 1)
        {Sample => clickKilla => out;
            Sample =< out;}
        if(selector == 1 && clickKillaVal == 1)
        {Sample => clickKilla => Lisa;   
            Sample =< Lisa;}
    }
    
    //If routing through LiSa, you can loop a selection of the cut up sample running. 
    //This helps turn total/partial randomness into some hot-shit aleatoricism/improvisation. 
    //Unsporking this feature is still being fixed, but aside from that it should be pretty much fully functional
    //- so if a song is based off of one long loop it's definitely "useable" 
    fun void loop(int on, int speed, int LoopLength)
    {
        if(on == 1)
        {
            0 => int iter8;
            (speed * LoopLength)::samp => Lisa.duration;
            Lisa.loop(1);
            Lisa.record(1);
            
            while(iter8 < LoopLength){
                speed::samp => now;
                iter8++;}
            Sample =< g;                
            while(true){
                Lisa.record(0);
                Lisa.rate(1);
                Lisa.play(1);
                (speed * LoopLength)::samp => now;  
            }
                        
        }
        else{<<<"switch loop on, dingus">>>;}
    }
    
    fun void sporkLoop(int on, int speed, int LoopLength)
    {
        Shred unsporkLoopShred;
        spork~ loop(on, speed, LoopLength) @=> unsporkLoopShred;
        unsporkLoopShred.id() => LoopId;
            <<<"Loop ID: " + LoopId>>>;
    }
    fun void unsporkLoop()
    {      <<<"getting thru, Loop">>>; //this is here to help with troubleshooting Loop Unsporking
            Machine.remove(LoopId);}
    
    //Rhythmic - Two setting function: 
    //Setting 0) Cuts samples at an input speed, according to rate values in an input array, with random positions between an input min and max sample
    //position. These can be set to the same so it always plays from the same position.
    //Setting 1) Basically a shortcut to an "always on" version of setting 1. Leaves out the array and just cuts on every speed value.
    fun void rhythmic(float array[], int speed, int positionMin, int positionMax, int setting)
    {
        if(positionMax > Sample.samples() || positionMin < 0)
        {<<<"Incorrect positioning, please position between 0 & " + Sample.samples() + " samples">>>;}
                
        (speed/100) => int swell;
         clickKilla.set(swell::samp, 0::samp, 1, swell::samp);
         <<<" swell: " + swell>>>; //informs you how much the ClickKilla is ramping. As I continue to develop it, this is going to become an easily changed static variable
        if(setting == 0)
        {
            while(true)
            {
                for(0 => int i; i < array.cap(); i++) 
                {
                    clickKilla.keyOn();
                    array[i] => Sample.rate;
                    Std.rand2(positionMin, (positionMax - speed)) => Sample.pos;
                    (speed - swell)::samp => now;
                    clickKilla.keyOff();
                    swell::samp => now;
                    
                }
            }
        }
        if(setting == 1)
        {
            while(true)
            {
                clickKilla.keyOn();
                1 => Sample.rate;
                Std.rand2(positionMin, (positionMax - speed)) => Sample.pos;
                (speed - swell)::samp => now;
                clickKilla.keyOff();
                swell::samp => now;
            }
           
        }
    }
    //function to sporks Rhythmic function for concurrency
    fun void sporkRhythmic(float array[], int speed, int positionMin, int positionMax, int setting)
    {
            Shred unsporkRhythmicShred;
            spork~ rhythmic(array, speed, positionMin, positionMax, setting) @=> unsporkRhythmicShred;
            unsporkRhythmicShred.id() => RhythmId;
            <<<"Rhythmic ID " + RhythmId>>>;
    }
    //function to unspork Rhythmic function when u get bored
    fun void unsporkRhythmic()
    {      <<<"getting thru, Rhythmic">>>; 
            Machine.remove(RhythmId);}
    
    //One Shot - 5 setting function:
    //User chooses a position, speed, and chance(percentage). Function rolls a dice every [speed] value and if it falls within the chosen percentage,
    //the sample with play from the chosen position.
    //0) 0% - sample plays once and only once
    //1) 25% - 25% chance of sample playing
    //2) 50% - 50% chance of sample playing
    //3) 75% - 75% chance of sample playing 
    //4) 100% - Sample plays once every [speed] value
    fun void oneShot(int position, int speed, int chanceSetting, float rate)
    {
        (speed/100) => int swell;
         clickKilla.set(swell::samp, 0::samp, 1, swell::samp);
         <<<" swell: " + swell>>>;
        if(chanceSetting == 0)
        {
            clickKilla.keyOn();
            rate => Sample.rate;
            position => Sample.pos;
            (speed - swell)::samp => now;
            clickKilla.keyOff();
            swell::samp => now;
        }
        
        if(chanceSetting == 25)
        {
            while(true)
            {
                Std.rand2(0, 100) => int diceRoll;
                if(diceRoll <= 25)
                {
                    clickKilla.keyOn();
                    rate => Sample.rate;
                    position => Sample.pos;
                    (speed - swell)::samp => now;
                    clickKilla.keyOff();
                    swell::samp => now;
                }
                else {speed::samp => now;}
            }
           
        }
        
        if(chanceSetting == 50)
        {
            while(true)
            {
                Std.rand2(0, 100) => int diceRoll;
                if(diceRoll <= 50)
                {
                    clickKilla.keyOn();
                    rate => Sample.rate;
                    position => Sample.pos;
                    (speed - swell)::samp => now;
                    clickKilla.keyOff();
                    swell::samp => now;
                }
                else {speed::samp => now;}
            }
           
        }
        
        if(chanceSetting == 75)
        {
            while(true)
            {
                Std.rand2(0, 100) => int diceRoll;
                if(diceRoll <= 75)
                {
                    clickKilla.keyOn();
                    rate => Sample.rate;
                    position => Sample.pos;
                    (speed - swell)::samp => now;
                    clickKilla.keyOff();
                    swell::samp => now;
                }
                else {speed::samp => now;}
            }
           
        }
        
        if(chanceSetting == 100)
        {
            while(true)
            {
                    clickKilla.keyOn();
                    rate => Sample.rate;
                    position => Sample.pos;
                    (speed - swell)::samp => now;
                    clickKilla.keyOff();
                    swell::samp => now;
            }
           
        }
    }
    //Sporks the One Shot function
    fun void sporkOneShot(int position, int speed, int chanceSetting, float rate)
    {
        Shred unsporkOneShotShred;
        spork~ oneShot(position, speed, chanceSetting, rate) @=> unsporkOneShotShred;
        
            unsporkOneShotShred.id() => oneShotId;
            <<<"One Shot ID: " + oneShotId>>>;
    }
    //Unsporks the One Shot function when u get irritated a.f. (probably cos it's set to 100% and ur sample sux?)
    fun void unsporkOneShot()
    {      <<<"getting thru, One Shot">>>;
            Machine.remove(oneShotId);}
     
    //Equals - 1 setting function:
    //Equals takes the sample and divides it into equal parts according to the size of an array given to it (it can do this with a whole sample, or just 
    //a portion, using the min and max inputs). It then plays each of these cuts sequentially, at the given [speed] value, at the rate/pitch of the values
    //included in the initial array. Unless you know your sample REEEALLY well, it will seem fairly ramdom, but it loops - which provides a nice 
    //feeling of consistency. Aditionally, playing around with the min and max values can yeild some nice results.   
    fun void equals(float array[], int speed, int min, int max)
    {
        (speed/100) => int swell;
         clickKilla.set(swell::samp, 0::samp, 1, swell::samp);
         <<<"swell: " + swell>>>;
        (max - min)/array.cap() => int divider;
        while(true)
        {
            for(0 => int i; i < array.cap(); i++) 
            {
                clickKilla.keyOn();
                array[i] => Sample.rate;
                if(i == 0){0 => Sample.pos;}
                else{divider * i => Sample.pos;}
                (speed - swell)::samp => now;
                clickKilla.keyOff();
                swell::samp => now;
            }
        }
    }
    //Sporks Equals function for concurrency
    fun void sporkEquals(float array[], int speed, int min, int max)
    {
        Shred unsporkEqualsShred;
        spork~ equals(array, speed, min, max) @=> unsporkEqualsShred;
        unsporkEqualsShred.id() => EqualsId;
            <<<"Equals ID " + EqualsId>>>;
    }
    //Unsporks Equals function for when u realize u don't know your samples well enough to use this properly yet
    fun void unsporkEquals()
    {      <<<"getting thru, Equals">>>;
            Machine.remove(EqualsId);}
}
