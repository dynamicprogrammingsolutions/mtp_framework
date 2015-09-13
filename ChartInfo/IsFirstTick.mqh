//

class CIsFirstTick
{
   protected:
      datetime lasttick;
      datetime lasttime;
      string _symbol;

   public:
      int timeframe;
      bool set;
      bool _isfirsttick;
      int waittime;
      
   public:
      CIsFirstTick(string in_symbol = "", int _timeframe = PERIOD_CURRENT)
      {         
         if (in_symbol == "") in_symbol = _Symbol;
         //if (_timeframe == PERIOD_CURRENT) _timeframe = _Period;
         
         set = true;
         _isfirsttick = false;
         lasttick = 0;
         lasttime = 0;
         _symbol = in_symbol;
         timeframe = _timeframe;
      }
      
      void Set(string in_symbol = "", int _timeframe = PERIOD_CURRENT)
      {
         set = true;
         if (in_symbol == "") in_symbol = _Symbol;
         //if (_timeframe == PERIOD_CURRENT) _timeframe = _Period;
         if (_symbol != in_symbol || _timeframe != timeframe) {
            _isfirsttick = false;
            lasttick = 0;
            lasttime = 0;
            _symbol = in_symbol;
            timeframe = _timeframe;
         }
         
      }
      
      void StartOfUse()
      {
         this.lasttime = 0;
      }
      
      bool isfirsttick()
      {         
         if (this.lasttime != TimeCurrent()) {
            datetime bartime = iTime(_symbol,timeframe,0);
            if (this.lasttick == 0) this.lasttick = bartime;
            if (bartime == this.lasttick)
            {
               this._isfirsttick = false;
            }
            else
            {
               if (waittime == 0 || TimeCurrent() >= bartime+waittime) {
                  this.lasttick = bartime;
                  this._isfirsttick = true;
               } else {
                  this._isfirsttick = false;
               }
            }
            this.lasttime = TimeCurrent();
         } else {
            this._isfirsttick = false;
         }
         return(this._isfirsttick);   
      }
};

CIsFirstTick* objisfirsttick;

bool isfirsttick;

bool isfirsttick(ENUM_TIMEFRAMES _timeframe = PERIOD_CURRENT, string in_symbol = "")
{
   if (objisfirsttick == NULL) objisfirsttick = new CIsFirstTick(in_symbol,_timeframe);   
   objisfirsttick.waittime = 0;
   if (!objisfirsttick.set) {
      Print("Set Firsttick object");
      objisfirsttick.Set(in_symbol,_timeframe);
   }
   isfirsttick = objisfirsttick.isfirsttick();
   return(isfirsttick);
}

bool isfirsttick_waittime(int waittime, ENUM_TIMEFRAMES _timeframe = PERIOD_CURRENT, string in_symbol = "")
{
   if (objisfirsttick == NULL) objisfirsttick = new CIsFirstTick(in_symbol,_timeframe);   
   objisfirsttick.waittime = waittime;
   if (!objisfirsttick.set) {
      Print("Set Firsttick object");
      objisfirsttick.Set(in_symbol,_timeframe);
   }
   isfirsttick = objisfirsttick.isfirsttick();
   return(isfirsttick);
}