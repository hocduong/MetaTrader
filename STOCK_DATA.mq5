//+------------------------------------------------------------------+
//|                                                   UpdateData.mq5 |
//|                                                 Gogojungle Corp. |
//|                                        https://gogojungle.co.jp/ |
//+------------------------------------------------------------------+
#property copyright "Gogojungle Corp."
#property link      "https://gogojungle.co.jp/"
#property version   "1.00"
input int    Interval    =3600;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(Interval); 
//---
   return(INIT_SUCCEEDED);
  }
  

string GetData(string symbol)
   {
   
      string resquest_api = "https://www.hsx.vn/Modules/Chart/StaticChart/GetBasicChart";
   
      string request_headers,result_headers, temp_string; 
      char data[],result[]; 
      int resquest; 
      int timeout=5000;
          
      temp_string = StringFormat("?symbolString=%s",symbol);
      StringAdd(resquest_api,temp_string);
      temp_string = StringFormat("&rangeSelector=7&_=%d",(long)TimeCurrent());
      StringAdd(resquest_api,temp_string);
       
      ResetLastError(); 
   //--- Loading request
      resquest=WebRequest("GET",resquest_api,request_headers,timeout,data,result,result_headers); 
      
   //--- Checking errors 
      if(resquest == 200) 
        { 
         //--- Load successfully 
        PrintFormat("The resquest api has been successfully loaded, size =%d bytes.",ArraySize(result));                    
        } 
      else 
        {        
         PrintFormat("Error in WebRequest. Error code  =%d",GetLastError()); 
         MessageBox("Add the address '"+resquest_api+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);      
        }
        
        return CharArrayToString(result);
     
   }
   
int updateData(string data, string symbol)
   {
      int updated =0;
       
      string json_header = "[{\"ChartPoints\":[{";
      string json_footer = "}]}]";
      string empty = "";
      string json_separator_object = "},{";
      string json_separator_code = "_";
      
      
      StringReplace(data,json_header,empty);
      StringReplace(data,json_footer,empty);
      StringReplace(data,json_separator_object,json_separator_code);
      
      string history_list[]; 
      
     int replaced = StringSplit(data,StringGetCharacter(json_separator_code,0) ,history_list); 
     
     PrintFormat("number date of data collected =%d.",replaced);
      
     if(replaced>0) 
     {
      MqlRates mql_history_list[]; 
      
      ArrayResize(mql_history_list,replaced); 
      
      for(int i=0; i<replaced; i++) 
        {         
          map(history_list[i],mql_history_list[i]) ;
        } 

        updated = CustomRatesReplace(symbol,mql_history_list[0].time, mql_history_list[replaced -1].time,mql_history_list );
        
        PrintFormat("Number of updated bars =%d. Latest date =%s ",updated, TimeToString(mql_history_list[replaced -1].time) );
     }
      
      return updated;
   }
   
void map(string &json_history, MqlRates &mql_history)
{
   string json_attribute_code = ",";
   string json_keyvalue_code = ":";
   string attribute_list[]; 
   
   int attribute_number = StringSplit(json_history,StringGetCharacter(json_attribute_code,0) ,attribute_list); 
   if(attribute_number>0) 
     { 
      string attribute[]; 
      string key;
      double  value;              
      mql_history.spread = 0;
      
      for(int i=0; i<attribute_number; i++) 
        {         
          StringSplit(attribute_list[i],StringGetCharacter(json_keyvalue_code,0) ,attribute); 
          key = attribute[0];
          value = StringToDouble(attribute[1]);
          
          if(StringCompare(key, "\"Time\"") ==0)
          {
             mql_history.time = (datetime) value/1000; // convert from milisecond to second
          }
          else if(StringCompare(key, "\"OpenPrice\"") ==0)
          {
             mql_history.open = value;
          }
          else if(StringCompare(key, "\"ClosePrice\"") ==0)
          {
             mql_history.close = value;
          }
          else if(StringCompare(key, "\"HighPrice\"") ==0)
          {
             mql_history.high = value;
          }
          else if(StringCompare(key, "\"LowPrice\"") ==0)
          {
             mql_history.low = value;
          }
          else if(StringCompare(key, "\"TotalShare\"") ==0)
          {
             mql_history.real_volume = (long)value;
             mql_history.tick_volume = (long)value;
          }
        
        } 
     }
   
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   string symbol= Symbol();
    
   string json_result =  GetData(symbol);
      
    if(updateData(json_result, symbol) > 0) 
    {
     Comment( symbol + " UPDATED AT " + TimeToString(TimeLocal()));
    }else
    {
     MessageBox(symbol + " ERROR UPDATE " + TimeToString(TimeLocal())); 
    }
  }
//+------------------------------------------------------------------+
