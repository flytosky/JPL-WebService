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
      //$("#startYear").html("start year-month: (earliest:" + sTime + ")");
      //$("#endYear").html("end year-month: (latest:" + eTime + ")");
    }


