//+------------------------------------------------------------------+
//|                                                TRAINING_DATA.mq5 |
//|                                                 Gogojungle Corp. |
//|                                        https://gogojungle.co.jp/ |
//+------------------------------------------------------------------+
#property script_show_inputs
#property copyright "Gogojungle Corp."
#property link      "https://gogojungle.co.jp/"
#property version   "1.00"

//{symbol:HPG,RSI:14,StdDev:5,StdDev:10,MA:5,MA:10}{symbol:EURJPY,MA:5,MA:10}";
input string    ListIndicator="{symbol:HPG,OBV:1,MA:5,PSY:12}";
input int       numberOfBars=20;

string IndicatorProvider = "MA,RSI,StdDev,OBV,PSY";
ENUM_TIMEFRAMES     period ;

struct IndicatorData 
  { 
   string indicator_name;   
   double indicator_data[];  

  };
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
  
   period = Period();

   string  file_name = Symbol() + "_" + EnumToString(period) +".dat";
   
   string list_symbol[];
   string list_indicator_name;
   IndicatorData indicator_data_buffer[];
   
   // map user indicators to list defined indicators struct
   int symbol_number =  GetListSymbolIndicator(ListIndicator, list_symbol);
   // check number symbol
   if(symbol_number >0) 
   {  
      list_indicator_name =  GetIndicatorName(list_symbol);
      StringTrimRight(list_indicator_name);
      StringTrimLeft(list_indicator_name);
      int number_indicator = GetIndicatorBuffer(list_indicator_name, indicator_data_buffer);   
      if(number_indicator >0)
      {
         SaveData(file_name, list_indicator_name, indicator_data_buffer);
      }         
   }
   
  }


// Get date as int number
int GetDate(datetime current)
 {
      MqlDateTime timeStruct;
      TimeToStruct(current,timeStruct);     
      return  (timeStruct.year * 100  +  timeStruct.mon)*100 +  timeStruct.day;
 }
 
 
double GetDailyReturn(double current, double last)
{
   return ((current - last)*100 / last);
}
 
 
int SaveData(string file_name, string list_indicator_name, IndicatorData & indicator_data_buffer[])
{
   int fileHandle=FileOpen(file_name,FILE_WRITE|FILE_CSV);

   MqlRates  rates_array[];
   int icurrent=CopyRates(Symbol(),period,0,numberOfBars,rates_array);
   ArraySetAsSeries(rates_array,true);
   
   string outputData;
   StringAdd(outputData, "TIME ");
   StringAdd(outputData, list_indicator_name);  
   StringAdd(outputData, " PRICE TREND");
   StringAdd(outputData, "\n");
   for(int i= icurrent -2; i > 0; i--) 
     {
        // TIME
        StringAdd(outputData, IntegerToString(GetDate(rates_array[i].time)));
        
        // LIST INDICATOR
        for(int j= 0; j < ArraySize(indicator_data_buffer); j++) 
          {
             StringAdd(outputData, " ");
             StringAdd(outputData, DoubleToString(GetDailyReturn(indicator_data_buffer[j].indicator_data[i], indicator_data_buffer[j].indicator_data[i +1]),2));

          }
          
        //PRICE         
        StringAdd(outputData, " ");  
        StringAdd(outputData, DoubleToString(rates_array[i -1].open ,0)); 
        
        // TREND
        StringAdd(outputData, " ");  
        StringAdd(outputData, DoubleToString(GetDailyReturn(rates_array[i -1].close, rates_array[i].close),2));
        
        StringAdd(outputData, "\n");
     
     }
   FileWriteString(fileHandle,outputData);  
   return 0;
}


int GetIndicatorBuffer(string& list_indicator_name, IndicatorData & indicator_data_buffer[])
{  
    int number_indicator =0;
    string list_indicator[];
    string indicator_information[];
    StringSplit(list_indicator_name,StringGetCharacter(" ",0) ,list_indicator); 
    ArrayResize(indicator_data_buffer,ArraySize(list_indicator)); 
   for(int i=0; i< ArraySize(list_indicator); i++) 
      {
         indicator_data_buffer[i].indicator_name = list_indicator[i];
         StringSplit(list_indicator[i],StringGetCharacter("_",0) ,indicator_information);
         
         if(ArraySize(indicator_information) == 3 && StringCompare(indicator_information[1], "MA") ==0)
         {
            int maHandle=iMA(indicator_information[0],period,(int)indicator_information[2],0,MODE_SMA,PRICE_CLOSE);
            CopyBuffer(maHandle,0,0,numberOfBars,indicator_data_buffer[i].indicator_data);
            ArraySetAsSeries(indicator_data_buffer[i].indicator_data,true);
            number_indicator ++;
         }
         else if(ArraySize(indicator_information) == 3 && StringCompare(indicator_information[1], "RSI") ==0)              
         {            
            int rsiHandle= iRSI(indicator_information[0],period,(int)indicator_information[2],PRICE_CLOSE);
            CopyBuffer(rsiHandle,0,0,numberOfBars,indicator_data_buffer[i].indicator_data);
            ArraySetAsSeries(indicator_data_buffer[i].indicator_data,true);
            number_indicator ++;
         }
         else if(ArraySize(indicator_information) == 3 && StringCompare(indicator_information[1], "StdDev") ==0)              
         {            
            int StdDevHandle = iStdDev(indicator_information[0],period,(int)indicator_information[2],0,MODE_SMA,PRICE_CLOSE); 
            CopyBuffer(StdDevHandle,0,0,numberOfBars,indicator_data_buffer[i].indicator_data);
            ArraySetAsSeries(indicator_data_buffer[i].indicator_data,true);
            number_indicator ++;
         }         
         else if(ArraySize(indicator_information) == 3 && StringCompare(indicator_information[1], "OBV") ==0)              
         {            
            int OBVHandle = iOBV(indicator_information[0],period,VOLUME_TICK); 
            CopyBuffer(OBVHandle,0,0,numberOfBars,indicator_data_buffer[i].indicator_data);
            ArraySetAsSeries(indicator_data_buffer[i].indicator_data,true);
            number_indicator ++;
         }
         else if(ArraySize(indicator_information) == 3 && StringCompare(indicator_information[1], "PSY") ==0)              
         {            
            int PSYHandle = iCustom(indicator_information[0],period,indicator_information[1],(int)indicator_information[2] ); 
            CopyBuffer(PSYHandle,0,0,numberOfBars,indicator_data_buffer[i].indicator_data);
            ArraySetAsSeries(indicator_data_buffer[i].indicator_data,true);
            number_indicator ++;
         }
         
      }

   return number_indicator ++;;
}


  
string GetIndicatorName(string& list_symbol[])
{
   string list_indicator_names;
   string list_attribute[]; 
   for(int i=0; i< ArraySize(list_symbol); i++) 
      {
         StringSplit(list_symbol[i],StringGetCharacter(",",0) ,list_attribute);         
         if(ArraySize(list_attribute) >0)
         {
            string symbol = GetAttributeValue("symbol", list_attribute);
            string key;
            string valuel;
            for(int j=0; j< ArraySize(list_attribute); j++) 
               {
                  key = GetAttributeKey(list_attribute[j]);
                  if(StringFind(IndicatorProvider, key) >=0)
                  {
                    valuel =  GetAttributeValue(list_attribute[j]);
                    StringAdd(list_indicator_names,symbol + "_" + key + "_" + valuel + " ");
                  }
               }           
         }
      }
   return list_indicator_names;

}

string GetAttributeValue(string key, string& list_attribute[])
{
      string result = "";
      string key_value[]; 
      for(int i=0; i< ArraySize(list_attribute); i++) 
      {
         StringSplit(list_attribute[i],StringGetCharacter(":",0) ,key_value); 
         if(ArraySize(key_value) == 2 && StringCompare(key_value[0], key) ==0)
         {
             result = key_value[1];
             break;
         }
      }
      
      return result;
}

string GetAttributeKey(string attribute)
{
      string result = "";
      string key_value[]; 
      StringSplit(attribute,StringGetCharacter(":",0) ,key_value); 
      if(ArraySize(key_value) == 2)
      {
         result = key_value[0];
      }
      return result;
}

string GetAttributeValue(string attribute)
{
      string result = "";
      string key_value[]; 
      StringSplit(attribute,StringGetCharacter(":",0) ,key_value); 
      if(ArraySize(key_value) == 2)
      {
         result = key_value[1];
      }
      return result;
}

  
//+------------------------------------------------------------------+

int GetListSymbolIndicator(string source, string& destination[] )
{
   string list_symbol_indicator[]; 

   string json_open_bracket = "{";
   string json_close_bracket = "}";
   
   StringReplace(source,json_close_bracket, "" );
   int splited = StringSplit(source,StringGetCharacter(json_open_bracket,0) ,list_symbol_indicator); 
   
   if(splited >0) 
   {    
      ArrayResize(destination,splited -1); 
      for(int i=1; i< splited; i++) 
        {         
            destination[i-1] = list_symbol_indicator[i];
        } 
   }
   return ArraySize(destination);
}