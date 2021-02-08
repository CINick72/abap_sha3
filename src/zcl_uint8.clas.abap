class zcl_uint8 definition
  public
  final.

  public section.

    types: uint8 type zuint8.
    types: t_uint8 type zuint8_t.

    class-data: powers_of_2 type table of decfloat34.

    class-methods to_decfloat34
      importing
                iv_value        type uint8
      returning value(rv_value) type decfloat34.

    class-methods from_decfloat34
      importing
                iv_value        type decfloat34
      returning value(rv_value) type uint8.

    class-methods shift_left
      importing
                iv_value        type uint8
                iv_places       type int4
      returning value(rv_value) type uint8.

    class-methods shift_right
      importing
                iv_value        type uint8
                iv_places       type int4
      returning value(rv_value) type uint8.

    class-methods class_constructor.

endclass.



class zcl_uint8 implementation.

  method to_decfloat34.

    rv_value = 0.
    do 64 times.
      get bit sy-index of iv_value into data(bit).
      if bit = 1.
        data(idx) = 65 - sy-index.
        read table powers_of_2 into data(ls_power) index idx.
        rv_value = rv_value + ls_power.
      endif.
    enddo.

  endmethod.

  method class_constructor.

    data: two type decfloat34.
    two = 2.
    data: power type decfloat34.
    power = 1.

    append power to powers_of_2.

    do 63 times.
      power = power * two.
      append power to powers_of_2.
    enddo.

  endmethod.

  method from_decfloat34.

    "todo make quicker
    data: lv_value type decfloat34.
    lv_value = iv_value.
    do 64 times.
      data(idx) = 65 - sy-index.
      read table powers_of_2 into data(ls_power) index idx.
      if lv_value div ls_power <> 0.
        set bit sy-index of rv_value to 1.
        lv_value = lv_value - ls_power.
      endif.
    enddo.


  endmethod.

  method shift_left.

    data(lv_bytes) = iv_places div 8.
    data(lv_bites) = iv_places mod 8.

    rv_value = iv_value.
    shift rv_value left by lv_bytes places in byte mode.

    if lv_bites <> 0.
      read table powers_of_2 into data(lv_multi) index lv_bites + 1.

      data: lv_left_bytes  type zuint8,
            lv_mid_bytes   type zuint8,
            lv_right_bytes type zuint8.

      lv_left_bytes = '0000000000' && rv_value(3).
      lv_left_bytes = lv_left_bytes * lv_multi.
      shift lv_left_bytes left by 5 places in byte mode.

      lv_mid_bytes = '000000000000' && rv_value+3(2).
      lv_mid_bytes = lv_mid_bytes * lv_multi.
      shift lv_mid_bytes left by 3 places in byte mode.

      lv_right_bytes = '0000000000' && rv_value+5(3).
      lv_right_bytes = lv_right_bytes * lv_multi.

      rv_value = lv_left_bytes bit-or lv_mid_bytes bit-or lv_right_bytes.
    endif.

*    data(lv_idx) = iv_places + 1.
*    while lv_idx <= 64.
*      get bit lv_idx of iv_value into data(bit).
*      if bit = 1.
*        data(lv_bit_idx) = lv_idx - iv_places.
*        set bit lv_bit_idx of rv_value.
*      endif.
*      lv_idx = lv_idx + 1.
*    endwhile.

  endmethod.

  method shift_right.

    data(lv_bytes) = iv_places div 8.
    data(lv_bites) = iv_places mod 8.

    rv_value = iv_value.
    shift rv_value right by lv_bytes places in byte mode.

    if lv_bites <> 0.
      read table powers_of_2 into data(lv_multi) index lv_bites + 1.

      data: lv_ffffff type zuint8.
      case lv_bites.
        when 1.
          lv_ffffff = '000000007FFFFFFF'.
        when 2.
          lv_ffffff = '000000003FFFFFFF'.
        when 3.
          lv_ffffff = '000000001FFFFFFF'.
        when 4.
          lv_ffffff = '000000000FFFFFFF'.
        when 5.
          lv_ffffff = '0000000007FFFFFF'.
        when 6.
          lv_ffffff = '0000000003FFFFFF'.
        when 7.
          lv_ffffff = '0000000001FFFFFF'.
      endcase.

      data: lv_left_bytes  type zuint8,
            lv_mid_bytes   type zuint8,
            lv_right_bytes type zuint8.

      lv_left_bytes = '00000000' && rv_value(1).
      lv_left_bytes = lv_left_bytes div lv_multi.
      lv_left_bytes = lv_left_bytes bit-and lv_ffffff.
      shift lv_left_bytes left by 4 places in byte mode.

      lv_mid_bytes = '00000000' && rv_value+1(3).
      lv_mid_bytes = lv_mid_bytes div lv_multi.
      lv_mid_bytes = lv_mid_bytes bit-and lv_ffffff.
      shift lv_mid_bytes left by 3 places in byte mode.

      lv_right_bytes = '00000000' && rv_value+4(4).
      lv_right_bytes = lv_right_bytes div lv_multi.
      lv_right_bytes = lv_right_bytes bit-and lv_ffffff.

      rv_value = lv_left_bytes bit-or lv_mid_bytes bit-or lv_right_bytes.

      rv_value = lv_left_bytes bit-or lv_mid_bytes bit-or lv_right_bytes.
    endif.

*    data(lv_bits) = 64 - iv_places.
*    data(lv_idx) = 1.
*    while lv_idx <= lv_bits.
*      get bit lv_idx of iv_value into data(bit).
*      if bit = 1.
*        data(lv_bit_idx) = lv_idx + iv_places.
*        set bit lv_bit_idx of rv_value.
*      endif.
*      lv_idx = lv_idx + 1.
*    endwhile.

  endmethod.

endclass.
