    // disable download data button
    function disable_download_button()
    {
      var x=document.getElementById("download_data");
      x.disabled=true;
    }

    // enable download data button
    function enable_download_button()
    {
      var x=document.getElementById("download_data");
      x.disabled=false;
    }

    // disable pressure level box for 2D var
    function disable_pres1(ID)
    {
      var x;
      x=document.getElementById("pres"+ID);
      x.value = "N/A";
      x.disabled=true;
    }

    // enable pressure level box for 3D var
    function enable_pres1(ID)
    {
      var x;
      x=document.getElementById("pres"+ID);
      x.value = "500";
      x.disabled=false;
    }

    function put_data(ID){
      var list1=document.getElementById("data"+ID);

      for(var key in dataList) {
        if (key.slice(0,5)==="group") {
          var og = document.createElement("OPTGROUP");
          og.setAttribute('label', dataList[key][0]);
          list1.add(og);
        } else {
          og.appendChild(new Option(key,key));
        }
      }
    }

    function put_var(ID) {
      var list1=document.getElementById("var"+ID);
      for (var i=list1.length-1; i>=0; i--) {
      list1.remove(i);
      }

      data_string =  document.getElementById("data"+ID).value;
      var varList2 = dataList[data_string][1];  
      for (var i=0; i<varList2.length; i++) {
        var k = varList2[i];
        list1.add(new Option(varList[k][0],k));
      }
    
    }

    // 
    function select_var(ID)
    {
      var var_string = $("#var"+ID).val();

      // alert("var_string: " + var_string)

      if (varList[var_string][2]===3) {
        enable_pres1(ID);
      } else {
        disable_pres1(ID);
      }

      //alert("variable1: " + var_string);

    }

    function time_range() {
      var var_string1 = $("#var"+1).val();
      var data_string1 = $("#data"+1).val();

      var sTime = dataList[data_string1][2][var_string1][0].toString();
      var eTime = dataList[data_string1][2][var_string1][1].toString();

      $("#startYear").html("start year-month: (earliest:" + sTime.slice(0,4) + "-" + sTime.slice(4,6) + ")");
      $("#endYear").html("end year-month: (latest:" + eTime.slice(0,4) + "-" + eTime.slice(4,6) + ")");
    }

    function time_range2() {
      var var_string1 = $("#var"+1).val();
      var var_string2 = $("#var"+2).val();
      var data_string1 = $("#data"+1).val();
      var data_string2 = $("#data"+2).val();

      var sTime = Math.max( Number(dataList[data_string1][2][var_string1][0]),
                            Number(dataList[data_string2][2][var_string2][0]) ).toString();
      var eTime = Math.min( Number(dataList[data_string1][2][var_string1][1]),
                            Number(dataList[data_string2][2][var_string2][1]) ).toString();

      //sTime = sTime.toString();
      //eTime = eTime.toString();

      $("#startYear").html("start year-month: (earliest:" + sTime.slice(0,4) + "-" + sTime.slice(4,6) + ")");
      $("#endYear").html("end year-month: (latest:" + eTime.slice(0,4) + "-" + eTime.slice(4,6) + ")");
    }

    function time_range3() {
      var var_string1 = $("#var"+1).val();
      var var_string2 = $("#var"+2).val();
      var var_string3 = $("#var"+3).val();
      var data_string1 = $("#data"+1).val();
      var data_string2 = $("#data"+2).val();
      var data_string3 = $("#data"+3).val();

      var sTime = Math.max( 
           Number(dataList[data_string1][2][var_string1][0]),
           Number(dataList[data_string2][2][var_string2][0]),
           Number(dataList[data_string3][2][var_string3][0]) 
           ).toString();
      var eTime = Math.min(
           Number(dataList[data_string1][2][var_string1][1]),
           Number(dataList[data_string2][2][var_string2][1]),
           Number(dataList[data_string3][2][var_string3][1]) 
           ).toString();

      //sTime = sTime.toString();
      //eTime = eTime.toString();

      $("#startYear").html("start year-month: (earliest:" + sTime.slice(0,4) + "-" + sTime.slice(4,6) + ")");
      $("#endYear").html("end year-month: (latest:" + eTime.slice(0,4) + "-" + eTime.slice(4,6) + ")");
      //$("#startYear").html("start year-month: (earliest:" + sTime + ")");
      //$("#endYear").html("end year-month: (latest:" + eTime + ")");
    }

var monthList = [
"Jan",
"Feb",
"Mar",
"Apr",
"May",
"Jun",
"Jul",
"Aug",
"Sep",
"Oct",
"Nov",
"Dec",
];

  function fillMonth() { 
    var temp1 = 'select months:\
<select name="months" id="months" onchange="select_months()">\
<option id="all">select all</option>\
<option id="none">select none</option>\
<option id="summer">Summer:Jun-Jul-Aug</option>\
<option id="autum">Autumn:Sep-Oct-Nov</option>\
<option id="winter">Winter:Dec-Jan-Feb</option>\
<option id="spring">Spring:Mar-Apr-May</option> </select>';
    $("#monthSelect0").html(temp1); 

    temp1 = ""; 
    for (var i=0; i<monthList.length; i++) {
      temp1 +=
         '<input type="checkbox" id="' + monthList[i] + '" value="' + monthList[i] + '"/>' 
            +  monthList[i] + " ";
    }
    $("#monthSelect").html(temp1); 
  }

    // unselect all months in the checkboxes
    function reset_months()
    {
      for (var i=0; i<monthList.length; i++) {
        document.getElementById(monthList[i]).checked = false;
      }
    }

    // see if no month is selected
    function no_month_check()
    {
      var nonChecked = true;
      for (var i=0; i<monthList.length; i++) {
        if (document.getElementById(monthList[i]).checked == true) {
          nonChecked = false;
        }
      }
      return nonChecked;
    }

    // select all months in the checkboxes
    function select_all_months()
    {
      for (var i=0; i<monthList.length; i++) {
        document.getElementById(monthList[i]).checked = true;
      }
    }

    // select checkboxes based on "months" dropdown
    function select_months()
    {
      var s1=document.getElementById("months");
      // alert(s1.selectedIndex);
      // alert(s1.options[s1.selectedIndex].value);

      // disable the download button because of this change
      disable_download_button();

      // "select none"
      if (s1.selectedIndex == 1) {
        reset_months();
      }
      // "select all"
      if (s1.selectedIndex == 0) {
        select_all_months();
      }
      // "summer"
      if (s1.selectedIndex == 2) {
        reset_months();
        document.getElementById('Jun').checked = true;
        document.getElementById('Jul').checked = true;
        document.getElementById('Aug').checked = true;
      }
      // "autumn"
      if (s1.selectedIndex == 3) {
        reset_months();
        document.getElementById('Sep').checked = true;
        document.getElementById('Oct').checked = true;
        document.getElementById('Nov').checked = true;
      }
      // "winter"
      if (s1.selectedIndex == 4) {
        reset_months();
        document.getElementById('Dec').checked = true;
        document.getElementById('Jan').checked = true;
        document.getElementById('Feb').checked = true;
      }
      // "spring"
      if (s1.selectedIndex == 5) {
        reset_months();
        document.getElementById('Mar').checked = true;
        document.getElementById('Apr').checked = true;
        document.getElementById('May').checked = true;
      }

    }

function getMonthStr() {
        // get months checked by client
        var month_str = "";
        for (var i=0; i<monthList.length; i++) {
          var mm = document.getElementById(monthList[i]);
          if (mm.checked == true) {
            month_str += ","+(i+1);
          }
        }
        month_str = month_str.substr(1);
        return month_str;
}

