#include "Loader.mqh"
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayInt.mqh>

class CIndicatorChange : public CAppObject
{
public:
   bool changed;
   bool newbar;
   datetime oldtime;
   datetime newtime;
   double oldvalue;
   double newvalue;

   weak_ptr<CIndicatorChange> lastbarchange;

   CIndicatorChange() {}
   CIndicatorChange(bool _changed, bool _newbar, datetime _oldtime, datetime _newtime, double _oldvalue, double _newvalue) :
      changed(_changed),
      newbar(_newbar),
      oldtime(_oldtime),
      newtime(_newtime),
      oldvalue(_oldvalue),
      newvalue(_newvalue)
   {}
   
   CIndicatorChange(const CIndicatorChange &src) :
      changed(src.changed),
      newbar(src.newbar),
      oldtime(src.oldtime),
      newtime(src.newtime),
      oldvalue(src.oldvalue),
      newvalue(src.newvalue)
   {}

   bool ChangedFromLastBar()
   {
      if (!lastbarchange.isset()) return false;
      CIndicatorChange* lbch = lastbarchange.get();
      //Print(lbch.newvalue," ",this.newvalue);
      return lbch.newvalue != this.newvalue;
   }

   bool Changed()
   {
      return !newbar && newvalue!=oldvalue;
   }

   bool ChangedOrNewBar()
   {
      return newbar || newvalue!=oldvalue;
   }

   bool NewBar()
   {
      return oldtime==0;
   }

};

class CIndicatorIndex : public CAppObject
{
public:
   int index;
   
   double values[];
   datetime times[];
   
   int totalvalues;
   
   CIndicatorChange changes[];
   
   CIndicatorIndex(int _index, int _totalvalues) : index(_index), totalvalues(_totalvalues)
   {
      ArrayResize(values,totalvalues);
      ArrayResize(times,totalvalues);
      ArrayResize(changes,totalvalues);
      ArrayInitialize(values,0);
      ArrayInitialize(times,0);

      for (int i = 0; i < totalvalues-1; i++) {
         changes[i].lastbarchange.reset(GetPointer(changes[i+1]));
      }
   }
   
   void stepvalues()
   {
      for (int i = totalvalues-1; i >= 0; i--) {
         if (i == 0) {
            values[i] = 0;
            times[i] = 0;
         } else {
            values[i] = values[i-1];
            times[i] = times[i-1];
         }
      }
   }
   
   bool SetValue(int bar, datetime time, double value)
   {
      while(times[bar] != 0 && times[bar] < time) {
         stepvalues();
      }
      changes[bar].oldvalue = values[bar];
      changes[bar].oldtime = times[bar];

      values[bar] = value;
      times[bar] = time;

      changes[bar].newvalue = value;
      changes[bar].newtime = time;

      changes[bar].newbar = changes[bar].NewBar();
      changes[bar].changed = changes[bar].ChangedOrNewBar();

      return changes[bar].changed;
   }

   double GetValue(int bar)
   {
      return values[bar];
   }

   CIndicatorChange* GetChange(int bar)
   {
      return GetPointer(changes[bar]);
   }
   
};

class CIndicator : public CAppObject
{
protected:

   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   int m_bars;

   CArrayObj indexes;
      
public:   

   CIndicatorIndex* index[];
   
   CIndicator()
   {
      
   }
   
   CIndicator(string _symbol, ENUM_TIMEFRAMES _timeframe, int bars, int _indexes) : m_symbol(_symbol), m_timeframe(_timeframe), m_bars(bars)
   {
      SetIndexes(_indexes);
   }
   
   void SetBars(int _bars)
   {
      m_bars = _bars;
   }
   
   void SetIndexes(int _indexes)
   {
      indexes.Clear();
      for (int i = 0; i < _indexes; i++)
         AddIndex(i);
   }
   
   void SetSymbol(string _symbol)
   {
      m_symbol = _symbol;
   }
   
   string GetSymbol()
   {
      return m_symbol;
   }
   
   void SetTimeframe(ENUM_TIMEFRAMES _timeframe)
   {
      m_timeframe = _timeframe;
   }
   
   void AddIndex(int idx)
   {
      if (m_bars == 0) EError("Bars not set");
      if (ArraySize(index) < idx+1) ArrayResize(index,idx+1);
      index[idx] = new CIndicatorIndex(idx,m_bars);
      indexes.Add(index[idx]);
   }

   double GetValue(int idx, int bar)
   {
      CIndicatorIndex* _index = indexes.At(idx);
      return _index.GetValue(bar);
   }
   
   CIndicatorChange* GetChange(int idx, int bar)
   {
      CIndicatorIndex* _index = indexes.At(idx);
      return _index.GetChange(bar);
   }

   bool GetFirstChange(int& _idx, int& in_bar)
   {
      for (int i = 0; i < indexes.Total(); i++) {
         CIndicatorIndex* _index = indexes.At(i);
         for (int bar = 0; bar < m_bars; bar++) {
            if (_index.changes[bar].changed && !_index.changes[bar].newbar) {
               _idx = i;
               in_bar = bar;
               return true;
            }
         }
      }
      return false;
   }
   virtual bool Call()
   {
      bool change = false;
      for (int i = 0; i < m_bars; i++) {
         if (Call(i)) change = true;
      }
      return change;
   }
   virtual bool Call(int bar)
   {
      bool change = false;
      for (int i = 0; i < indexes.Total(); i++) {
         CIndicatorIndex* _index = indexes.At(i);
         if (Call(_index,bar)) change = true;
      }
      return change;
   }   
   
   virtual bool Call(CIndicatorIndex &_index, int bar)
   {
      return _index.SetValue(bar,iTime(m_symbol,m_timeframe,bar),Execute(m_symbol,m_timeframe,_index.index,bar));
   }
   
   virtual double Execute(const string symbol, ENUM_TIMEFRAMES tf, int idx, int bar) { return 0; }
   
};
