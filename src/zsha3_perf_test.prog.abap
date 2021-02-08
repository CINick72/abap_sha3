*&---------------------------------------------------------------------*
*& Report ZSHA3_PERF_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSHA3_PERF_TEST.

parameters: p_norm radiobutton group 1.
parameters: p_input type text255.
parameters: p_cnt type i default 100.
parameters: p_long radiobutton group 1.
parameters: p_elong radiobutton group 1.

start-of-selection.

  data: lv_start type timestampl.
  data: lv_end type timestampl.
  data: lv_hash type string.
  if p_norm is not initial.
    get time stamp field lv_start.
    do p_cnt times.
    lv_hash = zcl_sha3=>hash512( iv_message = |{ p_input }| ).
    enddo.
    get time stamp field lv_end.
  elseif p_long is not initial.

    p_cnt = 1.
    data: lv_msg type string.
    do 1000000 times.
      lv_msg = lv_msg && 'a'.
    enddo.
    get time stamp field lv_start.
    lv_hash = zcl_sha3=>hash512( iv_message = lv_msg ).
    get time stamp field lv_end.

    write: / 'Expected: ', '3C3A876DA14034AB60627C077BB98F7E120A2A5370212DFFB3385A18D4F38859ED311D0A9D5141CE9CC5C66EE689B266A8AA18ACE8282A0E0DB596C90B0A7B87'.

  else.

    p_cnt = 1.
    data: lv_msg2repeat type string value 'abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmno'.
    data: lv_msg2repeat_x type xstring.
    call function 'SCMS_STRING_TO_XSTRING'
      exporting
        text = lv_msg2repeat
      importing
        buffer = lv_msg2repeat_x.

    data: lv_msg_x type xstring.
    do 16777216 times.
      lv_msg_x = lv_msg_x && lv_msg2repeat_x.
    enddo.

    get time stamp field lv_start.
    lv_hash = zcl_sha3=>hash512( iv_hex_message = lv_msg_x ).
    get time stamp field lv_end.

    write: / 'Expected: ', '235FFD53504EF836A1342B488F483B396EABBFE642CF78EE0D31FEEC788B23D0D18D5C339550DD5958A500D4B95363DA1B5FA18AFFC1BAB2292DC63B7D85097C'.

  endif.

  write: / 'SHA3-512: ', lv_hash.
  data(lv_elapsed) = cl_abap_tstmp=>subtract( tstmp1 = lv_end tstmp2 = lv_start ).
  write: / |{ p_cnt } rep.: { lv_elapsed } sec. -> 1 rep: { lv_elapsed / p_cnt } sec|.
