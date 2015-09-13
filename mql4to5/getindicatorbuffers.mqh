//+------------------------------------------------------------------------------+
//|                                                      GetIndicatorBuffers.mqh |
//|                                                             Copyright DC2008 |
//|                                                          http://www.mql5.com |
//+------------------------------------------------------------------------------+
#property copyright "DC2008"
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------------------+
//| копирует в массив значения индикатора с учётом порядка индексации            |
//+------------------------------------------------------------------------------+
bool CopyBufferAsSeries(
                        int handle,      // handle индикатора
                        int bufer,       // номер буфера индикатора
                        int start,       // откуда начнем
                        int number,      // сколько копируем
                        bool asSeries,   // порядок индексации массива
                        double &M[]      // массив, куда будут скопированы данные
                        )
  {
//--- заполнение массива M текущими значениями индикатора
   if(CopyBuffer(handle,bufer,start,number,M)<=0) return(false);
//--- задаём порядок индексации массива M
//--- если asSeries=true, то порядок индексации массива M как в таймсерии
//--- если asSeries=false, то порядок индексации массива M по умолчанию
   ArraySetAsSeries(M,asSeries);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора ADX с учётом индексации                |
//+------------------------------------------------------------------------------+
bool GetADXBuffers(int ADX_handle,
                   int start,
                   int number,
                   double &Main[],
                   double &PlusDI[],
                   double &MinusDI[],
                   bool asSeries=true  // индексация как в таймсерии
                   )
  {
//--- заполнение массива Main текущими значениями MAIN_LINE
   if(!CopyBufferAsSeries(ADX_handle,0,start,number,asSeries,Main)) return(false);
//--- заполнение массива PlusDI текущими значениями PLUSDI_LINE
   if(!CopyBufferAsSeries(ADX_handle,1,start,number,asSeries,PlusDI)) return(false);
//--- заполнение массива MinusDI текущими значениями MINUSDI_LINE
   if(!CopyBufferAsSeries(ADX_handle,2,start,number,asSeries,MinusDI)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора ADXWilder с учётом индексации          |
//+------------------------------------------------------------------------------+
bool GetADXWilderBuffers(int ADXWilder_handle,
                         int start,
                         int number,
                         double &Main[],
                         double &PlusDI[],
                         double &MinusDI[],
                         bool asSeries=true  // индексация как в таймсерии
                         )
  {
//--- заполнение массива Main текущими значениями MAIN_LINE
   if(!CopyBufferAsSeries(ADXWilder_handle,0,start,number,asSeries,Main)) return(false);
//--- заполнение массива PlusDI текущими значениями PLUSDI_LINE
   if(!CopyBufferAsSeries(ADXWilder_handle,1,start,number,asSeries,PlusDI)) return(false);
//--- заполнение массива MinusDI текущими значениями MINUSDI_LINE
   if(!CopyBufferAsSeries(ADXWilder_handle,2,start,number,asSeries,MinusDI)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора Аллигатор с учётом индексации          |
//+------------------------------------------------------------------------------+
bool GetAlligatorBuffers(int Alligator_handle,
                         int start,
                         int number,
                         double &Jaws[],
                         double &Teeth[],
                         double &Lips[],
                         bool asSeries=true  // индексация как в таймсерии
                         )
  {
//--- заполнение массива Jaws текущими значениями GATORJAW_LINE
   if(!CopyBufferAsSeries(Alligator_handle,0,start,number,asSeries,Jaws)) return(false);
//--- заполнение массива Teeth текущими значениями GATORTEETH_LINE
   if(!CopyBufferAsSeries(Alligator_handle,1,start,number,asSeries,Teeth)) return(false);
//--- заполнение массива Lips текущими значениями GATORLIPS_LINE
   if(!CopyBufferAsSeries(Alligator_handle,2,start,number,asSeries,Lips)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора Bands с учётом индексации              |
//+------------------------------------------------------------------------------+
bool GetBandsBuffers(int Bands_handle,
                     int start,
                     int number,
                     double &Base[],
                     double &Upper[],
                     double &Lower[],
                     bool asSeries=true  // индексация как в таймсерии
                     )
  {
//--- заполнение массива Base текущими значениями BASE_LINE
   if(!CopyBufferAsSeries(Bands_handle,0,start,number,asSeries,Base)) return(false);
//--- заполнение массива Upper текущими значениями UPPER_BAND
   if(!CopyBufferAsSeries(Bands_handle,1,start,number,asSeries,Upper)) return(false);
//--- заполнение массива Lower текущими значениями LOWER_BAND
   if(!CopyBufferAsSeries(Bands_handle,2,start,number,asSeries,Lower)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора Envelopes с учётом индексации          |
//+------------------------------------------------------------------------------+
bool GetEnvelopesBuffers(int Envelopes_handle,
                         int start,
                         int number,
                         double &Upper[],
                         double &Lower[],
                         bool asSeries=true       // индексация как в таймсерии
                         )
  {
//--- заполнение массива Upper текущими значениями UPPER_LINE
   if(!CopyBufferAsSeries(Envelopes_handle,0,start,number,asSeries,Upper)) return(false);
//--- заполнение массива Lower текущими значениями LOWER_LINE
   if(!CopyBufferAsSeries(Envelopes_handle,1,start,number,asSeries,Lower)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора Fractals с учётом индексации           |
//+------------------------------------------------------------------------------+
bool GetFractalsBuffers(int Fractals_handle,
                        int start,
                        int number,
                        double &Upper[],
                        double &Lower[],
                        bool asSeries=true       // индексация как в таймсерии
                        )
  {
//--- заполнение массива Upper текущими значениями UPPER_LINE
   if(!CopyBufferAsSeries(Fractals_handle,0,start,number,asSeries,Upper)) return(false);
//--- заполнение массива Lower текущими значениями LOWER_LINE
   if(!CopyBufferAsSeries(Fractals_handle,1,start,number,asSeries,Lower)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора Gator с учётом индексации              |
//+------------------------------------------------------------------------------+
bool GetGatorBuffers(int Gator_handle,
                     int start,
                     int number,
                     double &Upper[],
                     double &Lower[],
                     bool asSeries=true       // индексация как в таймсерии
                     )
  {
//--- заполнение массива Upper текущими значениями UPPER_LINE
   if(!CopyBufferAsSeries(Gator_handle,0,start,number,asSeries,Upper)) return(false);
//--- заполнение массива Lower текущими значениями LOWER_LINE
   if(!CopyBufferAsSeries(Gator_handle,1,start,number,asSeries,Lower)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора Ichimoku с учётом индексации           |
//+------------------------------------------------------------------------------+
bool GetIchimokuBuffers(int Ichimoku_handle,
                        int start,
                        int number,
                        double &Tenkansen[],
                        double &Kijunsen[],
                        double &SenkouspanA[],
                        double &SenkouspanB[],
                        double &Chinkouspan[],
                        bool asSeries=true       // индексация как в таймсерии
                        )
  {
//--- заполнение массива Tenkansen текущими значениями TENKANSEN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,0,start,number,asSeries,Tenkansen)) return(false);
//--- заполнение массива Kijunsen текущими значениями KIJUNSEN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,1,start,number,asSeries,Kijunsen)) return(false);
//--- заполнение массива SenkouspanA текущими значениями SENKOUSPANA_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,2,start,number,asSeries,SenkouspanA)) return(false);
//--- заполнение массива SenkouspanB текущими значениями SENKOUSPANB_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,3,start,number,asSeries,SenkouspanB)) return(false);
//--- заполнение массива Chinkouspan текущими значениями CHINKOUSPAN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,4,start,number,asSeries,Chinkouspan)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора MACD с учётом индексации               |
//+------------------------------------------------------------------------------+
bool GetMACDBuffers(int MACD_handle,
                    int start,
                    int number,
                    double &Main[],
                    double &Signal[],
                    bool asSeries=true       // индексация как в таймсерии
                    )
  {
//--- заполнение массива Main текущими значениями MAIN_LINE
   if(!CopyBufferAsSeries(MACD_handle,0,start,number,asSeries,Main)) return(false);
//--- заполнение массива Signal текущими значениями SIGNAL_LINE
   if(!CopyBufferAsSeries(MACD_handle,1,start,number,asSeries,Signal)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора RVI с учётом индексации                |
//+------------------------------------------------------------------------------+
bool GetRVIBuffers(int RVI_handle,
                   int start,
                   int number,
                   double &Main[],
                   double &Signal[],
                   bool asSeries=true       // индексация как в таймсерии
                   )
  {
//--- заполнение массива Main текущими значениями MAIN_LINE
   if(!CopyBufferAsSeries(RVI_handle,0,start,number,asSeries,Main)) return(false);
//--- заполнение массива Signal текущими значениями SIGNAL_LINE
   if(!CopyBufferAsSeries(RVI_handle,1,start,number,asSeries,Signal)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| копирует в массивы значния индикатора Stochastic с учётом индексации         |
//+------------------------------------------------------------------------------+
bool GetStochasticBuffers(int Stochastic_handle,
                          int start,
                          int number,
                          double &Main[],
                          double &Signal[],
                          bool asSeries=true       // индексация как в таймсерии
                          )
  {
//--- заполнение массива Main текущими значениями MAIN_LINE
   if(!CopyBufferAsSeries(Stochastic_handle,0,start,number,asSeries,Main)) return(false);
//--- заполнение массива Signal текущими значениями SIGNAL_LINE
   if(!CopyBufferAsSeries(Stochastic_handle,1,start,number,asSeries,Signal)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
