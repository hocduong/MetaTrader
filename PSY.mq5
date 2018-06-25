//+------------------------------------------------------------------+
//|                                                          PSY.mq5 |
//|                                                 Gogojungle Corp. |
//|                                        https://gogojungle.co.jp/ |
//+------------------------------------------------------------------+
#property copyright "Gogojungle Corp."
#property link      "https://gogojungle.co.jp/"
#property version   "1.00"
//--- indicator settings
#property indicator_separate_window
#property indicator_level1 0
#property indicator_level2 100
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
//--- input parameters
input int InpPeriodPSY=12; // Period
//--- indicator buffers
double    ExtPSYBuffer[];

//--- global variable
int       ExtPeriodPSY;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input

   if(InpPeriodPSY<1)
     {
      ExtPeriodPSY=12;
      Print("Incorrect value for input variable InpPeriodPSY =",InpPeriodPSY,
            "Indicator will use value =",ExtPeriodPSY,"for calculations.");
     }
   else ExtPeriodPSY=InpPeriodPSY;
   
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtPSYBuffer,INDICATOR_DATA);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"PSY("+string(ExtPeriodPSY)+")");
//--- initialization done
  }
  
  
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   int    i;
   double diff;
   double SumP=0.0;
   
//--- check for rates count
   if(rates_total<=ExtPeriodPSY)
      return(0);
      
//--- preliminary calculations
//--- bars handled on a previous calculate
   int pos=prev_calculated-1;
   if(pos<=ExtPeriodPSY)
     {
      //--- first RSIPeriod values of the indicator are not calculated
      ExtPSYBuffer[0]=0.0;
      
      for(i=1;i<=ExtPeriodPSY;i++)
        {
         ExtPSYBuffer[i]=0.0;
         diff=price[i]-price[i-1];
         SumP+=(diff>0?1:0);
        }
      
       ExtPSYBuffer[ExtPeriodPSY]= SumP *100 / ExtPeriodPSY;

      //--- prepare the position value for main calculation
      pos=ExtPeriodPSY+1;
     }
     
     
//--- the main loop of calculations
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
     
      SumP = ExtPSYBuffer[i -1] * ExtPeriodPSY / 100;
      
      // calculate curent position. 
      diff=price[i]-price[i-1];
      SumP+=(diff>0?1:0);
      
      // remove last start position.
      diff=price[i - ExtPeriodPSY]-price[i- ExtPeriodPSY -1];
      SumP-= (diff>0?1:0);
      
      ExtPSYBuffer[i]= SumP *100 / ExtPeriodPSY;

     }
     
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+