//+------------------------------------------------------------------+
//|                                                      signals.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+

#include "commonfunctions.mqh"
#include "arrays.mqh"
#include "comments.mqh"
#include "..\signals\Signal.mqh"
//#include "..\symbolinfoglobal.mqh"

/*#define SIGNAL_NO 0
#define SIGNAL_BUY 1
#define SIGNAL_SELL 2
#define SIGNAL_BOTH 3
#define SIGNAL_STRONGBUY 4
#define SIGNAL_STRONGSELL 5*/

int last_signal_[];
bool signal_changed_[];
datetime lastsignalbartime[];

int signaltocmd(int signal)
{
   if (signal == SIGNAL_BUY)
      return(OP_BUY);
   else if (signal == SIGNAL_SELL)
      return(OP_SELL);
   else
      return(-1);
}

string signalhandler_texts[] = {"Signal: ","Close Signal: ","Opposte Close Signal\n","Bar has not closed\n","No Change In Signal\n","Signal already has happened\n"};

class CSignalHandler
{
   protected:
      int last_signal_;
      bool signal_changed_;
      datetime lastsignalbartime;
      bool isfirstsignal(string in_symbol, int in_timeframe)
      {
         datetime bartime = iTime(in_symbol,in_timeframe,0);
         if (bartime == lastsignalbartime)
         {
            return(false);
         }
         else
         {
            lastsignalbartime = bartime;
            return(true);
         }
      }
   
   public:
      CIsFirstTick* isfirsttick;
      int timeframe;
      string _symbol;
      bool trade_only_firsttick;
      bool trade_only_signal_change;
      double oneperbar;
      bool trade_on_start;
      bool comments_enabled;
      bool reverse_strategy;
      bool opposite_close_signal_enabled;
      
      CSignalHandler(string in_symbol, int in_timeframe)
      {
         if (in_symbol == "") in_symbol = _Symbol;
         _symbol = in_symbol;
         isfirsttick = new CIsFirstTick(_symbol,in_timeframe);
         last_signal_= -1;
         signal_changed_= false;
         trade_only_firsttick = true;
         trade_only_signal_change = true;
         oneperbar = true;
         trade_on_start = false;
         comments_enabled = true;
         reverse_strategy = false;
         opposite_close_signal_enabled = false;
      }

      bool run(int& signal, int& closesignal, bool& enableopen)
      {
         if (comments_enabled) addcomment ("symbol: "+_symbol+"\n");
         if (reverse_strategy) signal = signal_reverse(signal);
         if (reverse_strategy) closesignal = signal_reverse(closesignal);
      
         if (comments_enabled) {
            addcomment(signalhandler_texts[0]/*"Signal: "*/+signaltext(signal)+"\n");  
            if (closesignal != SIGNAL_NO) addcomment(signalhandler_texts[1]/*"Close Signal: "*/+signaltext(closesignal,"NO SIGNAL","CLOSE SELL","CLOSE BUY","CLOSE ALL")+"\n");
         }
         
         if (!opposite_close_signal_enabled && signal != SIGNAL_NO && closesignal != SIGNAL_NO && signal != closesignal)
         {
            enableopen = false;
            if (comments_enabled) addcomment(signalhandler_texts[2]/*"Opposite Close Signal\n"*/);
         }
      
         //static int last_signal[MAXSIGNALHANDLERS] = {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};
         if (trade_on_start && last_signal_ == -1) last_signal_ = SIGNAL_NO;   
          
         if (!this.isfirsttick.isfirsttick() && this.trade_only_firsttick)
         {
            enableopen = false;
            if (comments_enabled) addcomment(signalhandler_texts[3]/*"Bar has not closed\n"*/);
         }
             
         if (this.trade_only_signal_change)
         {         
            if (this.last_signal_ != -1 && this.last_signal_ != signal && this.last_signal_ >= 0)
            {
               signal_changed_ = true;
            }
            this.last_signal_ = signal;
      
            if (!this.signal_changed_) {
               enableopen = false;
               if (comments_enabled) addcomment(signalhandler_texts[4]/*"No Change In Signal\n"*/);
            }
      
            if (enableopen && this.signal_changed_) {
               this.signal_changed_ = false;
            }
         }
         
         if (!this.trade_only_firsttick && signal != SIGNAL_NO && enableopen && this.oneperbar)
            if (!this.isfirstsignal(this._symbol, this.timeframe))
            {
               enableopen = false;
               if (this.comments_enabled) addcomment(signalhandler_texts[5]/*"signal already has happened\n"*/);
            }
      
         
         if (signal != SIGNAL_NO && enableopen) return(true);
         else return(false);
      }
};

int signal_wrapper(int signal, const string signalname, bool enabled = true, bool _comment = true)
{
   if (!enabled) return(SIGNAL_BOTH);      
   if (_comment && comments_enabled) addcomment("signal "+signalname+": "+signaltext(signal)+"\n");
   return(signal);  
}

int signal_wrapper_close(int signal, const string signalname, bool enabled = true, bool _comment = true)
{
   if (!enabled) return(SIGNAL_BOTH);      
   if (_comment && comments_enabled) addcomment("closesignal "+signalname+": "+signaltext_close(signal)+"\n");
   return(signal);  
}
