class zcl_sha3 definition
  public
  final
  create public .

  public section.

    class-methods hash224
      importing
                iv_message     type string  optional
                iv_hex_message type xstring optional
      returning value(rv_hash) type string.

    class-methods hash256
      importing
                iv_message     type string  optional
                iv_hex_message type xstring optional
      returning value(rv_hash) type string.

    class-methods hash384
      importing
                iv_message     type string  optional
                iv_hex_message type xstring optional
      returning value(rv_hash) type string.

    class-methods hash512
      importing
                iv_message     type string  optional
                iv_hex_message type xstring optional
      returning value(rv_hash) type string.

    class-methods class_constructor.

  protected section.
  private section.

    class-data: mt_rc type zuint8_t.
    class-data: mt_cc type zuint8_t.

    class-methods keccak1600
      importing
                iv_bitrate     type int4
                iv_capacity    type int4
                iv_message     type xstring
      returning value(rv_hash) type string.

    class-methods keccak_f
      changing
        ct_state type zuint8_m.

    class-methods rotate
      importing
                iv_value   type zuint8
                iv_digits  type int4
      returning value(rv_value) type zuint8.

    class-methods get_hash_from_state
      importing
        iv_capacity    type int4
        it_state       type zuint8_m
      returning
        value(rv_hash) type string.

endclass.


class zcl_sha3 implementation.

  method hash224.

    data: msg type xstring.

    if iv_hex_message is not supplied.
      call function 'SCMS_STRING_TO_XSTRING'
        exporting
          text   = iv_message
        importing
          buffer = msg
        exceptions
          others = 0.
    else.
      msg = iv_hex_message.
    endif.

    rv_hash = keccak1600( iv_bitrate = 1152 iv_capacity = 448 iv_message = msg ).

  endmethod.

  method hash256.

    data: msg type xstring.

    if iv_hex_message is not supplied.
      call function 'SCMS_STRING_TO_XSTRING'
        exporting
          text   = iv_message
        importing
          buffer = msg
        exceptions
          others = 0.
    else.
      msg = iv_hex_message.
    endif.

    rv_hash = keccak1600( iv_bitrate = 1088 iv_capacity = 512 iv_message = msg ).

  endmethod.

  method hash384.

    data: msg type xstring.

    if iv_hex_message is not supplied.
      call function 'SCMS_STRING_TO_XSTRING'
        exporting
          text   = iv_message
        importing
          buffer = msg
        exceptions
          others = 0.
    else.
      msg = iv_hex_message.
    endif.

    rv_hash = keccak1600( iv_bitrate = 832 iv_capacity = 768 iv_message = msg ).

  endmethod.

  method hash512.

    data: msg type xstring.

    if iv_hex_message is not supplied.
      call function 'SCMS_STRING_TO_XSTRING'
        exporting
          text   = iv_message
        importing
          buffer = msg
        exceptions
          others = 0.
    else.
      msg = iv_hex_message.
    endif.

    rv_hash = keccak1600( iv_bitrate = 576 iv_capacity = 1024 iv_message = msg ).

  endmethod.

  method keccak1600.

    data(lv_message) = iv_message.

    data(lv_padding) = 1. "0 - keccak, 1 - sha-3

    data(lv_msg_length) = xstrlen( lv_message ).

    data(lv_add_bytes) = ( iv_bitrate / 8 ) - lv_msg_length mod ( iv_bitrate / 8 ).

    data: c_86 type x value '86',
          c_06 type x value '06',
          c_00 type x value '00',
          c_80 type x value '80',
          c_81 type x value '81',
          c_01 type x value '01'.
    if lv_add_bytes = 1.
      lv_message = lv_message && cond #( when lv_padding = 0 then c_81 else c_86 ).
    else.
      lv_message = lv_message && cond #( when lv_padding = 0 then c_01 else c_06 ).
      do lv_add_bytes - 2 times.
        lv_message = lv_message && c_00.
      enddo.
      lv_message = lv_message && c_80.
    endif.

    data: lt_state type zuint8_m.
    do 5 times.
      append initial line to lt_state assigning field-symbol(<fs_state>).
      do 5 times.
        append value zuint8( ) to <fs_state>.
      enddo.
    enddo.

    data(iv_width) = 64.
    data(lv_blocksize) = iv_bitrate / iv_width * 8.

    lv_msg_length = xstrlen( lv_message ).
    data(lv_i) = 0.
    data(lv_j) = 0.
    data: lv_i64 type decfloat34.
    data: lv_places2shift type int4.
    data: lv_i64_adds type zuint8.
    while lv_i < lv_msg_length.
      lv_j = 0.
      while lv_j < iv_bitrate / iv_width.
        lv_i64 = 0.
        do 8 times.
          clear lv_i64_adds.

          data(lv_i64_idx) = sy-index - 1.
          data(lv_chr_idx) = lv_i + lv_j * 8 + lv_i64_idx.
          data(lv_chr) = lv_message+lv_chr_idx(1).

          lv_i64_adds+7(1) = lv_chr.
          lv_places2shift = 8 * lv_i64_idx.
          lv_i64_adds = zcl_uint8=>shift_left( iv_value = lv_i64_adds iv_places = lv_places2shift ).
          lv_i64 = lv_i64 + zcl_uint8=>to_decfloat34( lv_i64_adds ).
        enddo.

        data(x) = lv_j mod 5.
        data(y) = conv int4( floor( lv_j / '5.0' ) ).
        lt_state[ x + 1 ][ y + 1 ] = lt_state[ x + 1 ][ y + 1 ] bit-xor zcl_uint8=>from_decfloat34( lv_i64 ).
        lv_j = lv_j + 1.
      endwhile.
      keccak_f( changing ct_state = lt_state ).
      lv_i = lv_i + lv_blocksize.
    endwhile.

    rv_hash = get_hash_from_state( iv_capacity = iv_capacity it_state = lt_state ).

  endmethod.

  method keccak_f.

    constants: lv_rounds type int4 value 24.

    data(lv_round) = 0.
    data: lt_c type zuint8_t,
          lt_d type zuint8_t.
    while lv_round < lv_rounds.
      data(lv_x) = 0.

      clear: lt_c, lt_d.
      lt_c[] = mt_cc[].
      lt_d[] = mt_cc[].

      while lv_x < 5.
        lt_c[ lv_x + 1 ] = ct_state[ lv_x + 1 ][ 1 ].
        data(lv_y) = 1.
        while lv_y < 5.
          lt_c[ lv_x + 1 ] = lt_c[ lv_x + 1 ] bit-xor ct_state[ lv_x + 1 ][ lv_y + 1 ].
          lv_y = lv_y + 1.
        endwhile.
        lv_x = lv_x + 1.
      endwhile.

      lv_x = 0.
      while lv_x < 5.
        lt_d[ lv_x + 1 ] = lt_c[ ( ( lv_x + 4 ) mod 5 ) + 1 ] bit-xor rotate( iv_value = lt_c[ ( ( lv_x + 1 ) mod 5 ) + 1 ] iv_digits = 1 ).
        lv_y = 0.
        while lv_y < 5.
          ct_state[ lv_x + 1 ][ lv_y + 1 ] = ct_state[ lv_x + 1 ][ lv_y + 1 ] bit-xor lt_d[ lv_x + 1 ].
          lv_y = lv_y + 1.
        endwhile.
        lv_x = lv_x + 1.
      endwhile.

      lv_x = 1.
      lv_y = 0.

      data(lv_current) = ct_state[ lv_x + 1 ][ lv_y + 1 ].
      data(lv_t) = 0.
      while lv_t < 24.
        data(lv_xx) = lv_y.
        data(lv_yy) = ( 2 * lv_x + 3 * lv_y ) mod 5.
        data(lv_tmp) = ct_state[ lv_xx + 1 ][ lv_yy + 1 ].
        ct_state[ lv_xx + 1 ][ lv_yy + 1 ] = rotate( iv_value = lv_current iv_digits = ( ( ( lv_t + 1 ) * ( lv_t + 2 ) / 2 ) mod 64 ) ).
        lv_current = lv_tmp.
        lv_x = lv_xx.
        lv_y = lv_yy.
        lv_t = lv_t + 1.
      endwhile.

      lv_y = 0.
      while lv_y < 5.
        clear lt_c.
        lv_x = 0.
        while lv_x < 5.
          append ct_state[ lv_x + 1 ][ lv_y + 1 ] to lt_c.
          lv_x = lv_x + 1.
        endwhile.
        lv_x = 0.
        while lv_x < 5.
          ct_state[ lv_x + 1 ][ lv_y + 1 ] = ( lt_c[ lv_x + 1 ] bit-xor ( ( bit-not lt_c[ ( ( lv_x + 1 ) mod 5 ) + 1 ] ) bit-and lt_c[ ( ( lv_x + 2 ) mod 5 ) + 1 ] ) ).
          lv_x = lv_x + 1.
        endwhile.
        lv_y = lv_y + 1.
      endwhile.

      ct_state[ 1 ][ 1 ] = ct_state[ 1 ][ 1 ] bit-xor mt_rc[ lv_round + 1 ].

      lv_round = lv_round + 1.
    endwhile.


  endmethod.

  method rotate.
    data(lv_a_left_shifted) = zcl_uint8=>shift_left( iv_value = iv_value iv_places = iv_digits ).
    data(lv_a_right_shifted) = zcl_uint8=>shift_right( iv_value = iv_value iv_places = 64 - iv_digits ).
    rv_value = lv_a_left_shifted bit-or lv_a_right_shifted.
  endmethod.


  method get_hash_from_state.

    data lv_x type i.
    data lv_y type int4.

    data(lv_length_needed) = iv_capacity / 2.
    data(lv_output_length) = 0.
    data: lv_state_str type string.
    do 5 times.
      lv_x = sy-index.
      do 5 times.
        lv_y = sy-index.
        lv_state_str = it_state[ lv_y ][ lv_x ].
        rv_hash = rv_hash && lv_state_str+14(2) && lv_state_str+12(2) && lv_state_str+10(2) && lv_state_str+8(2) && lv_state_str+6(2) && lv_state_str+4(2) && lv_state_str+2(2) && lv_state_str(2).
        lv_output_length = lv_output_length + 64.
        if lv_output_length >= lv_length_needed.
          exit.
        endif.
      enddo.
      if lv_output_length >= lv_length_needed.
        exit.
      endif.
    enddo.

  endmethod.

  method class_constructor.

    mt_rc = value #(
               ( conv #( '0000000000000001' ) ) ( conv #( '0000000000008082' ) ) ( conv #( '800000000000808A' ) )
               ( conv #( '8000000080008000' ) ) ( conv #( '000000000000808B' ) ) ( conv #( '0000000080000001' ) )
               ( conv #( '8000000080008081' ) ) ( conv #( '8000000000008009' ) ) ( conv #( '000000000000008A' ) )
               ( conv #( '0000000000000088' ) ) ( conv #( '0000000080008009' ) ) ( conv #( '000000008000000A' ) )
               ( conv #( '000000008000808B' ) ) ( conv #( '800000000000008B' ) ) ( conv #( '8000000000008089' ) )
               ( conv #( '8000000000008003' ) ) ( conv #( '8000000000008002' ) ) ( conv #( '8000000000000080' ) )
               ( conv #( '000000000000800A' ) ) ( conv #( '800000008000000A' ) ) ( conv #( '8000000080008081' ) )
               ( conv #( '8000000000008080' ) ) ( conv #( '0000000080000001' ) ) ( conv #( '8000000080008008' ) )
         ).


    mt_cc = value #(
      ( conv #( '0000000000000000' ) )
      ( conv #( '0000000000000000' ) )
      ( conv #( '0000000000000000' ) )
      ( conv #( '0000000000000000' ) )
      ( conv #( '0000000000000000' ) )
    ).

  endmethod.

endclass.
