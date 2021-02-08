*"* use this source file for your ABAP unit test classes


class lcl_sha3_test definition for testing
  duration short
  risk level harmless
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>lcl_Sha3_Test
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>ZCL_SHA3
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL>X
*?</GENERATE_ASSERT_EQUAL>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  private section.
    data:
      f_cut type ref to zcl_sha3.  "class under test

    methods: hash512_abc for testing.

    methods: hash512_abc_hex for testing.

    methods: hash512_empty for testing.

    methods: hash512_448bits for testing.

    methods: hash512_896bits for testing.

endclass.       "lcl_Sha3_Test


class lcl_sha3_test implementation.

  method hash512_abc.

    data(rv_hash) = zcl_sha3=>hash512( iv_message = 'abc' ).
    cl_abap_unit_assert=>assert_equals(
      act   = rv_hash
      exp   = 'B751850B1A57168A5693CD924B6B096E08F621827444F70D884F5D0240D2712E10E116E9192AF3C91A7EC57647E3934057340B4CF408D5A56592F8274EEC53F0'
    ).

  endmethod.

  method hash512_abc_hex.

    data: lv_message type xstring.

    call function 'SCMS_STRING_TO_XSTRING'
      exporting
        text   = |abc|
      importing
        buffer = lv_message
      exceptions
        others = 0.

    data(rv_hash) = zcl_sha3=>hash512( iv_hex_message = lv_message ).
    cl_abap_unit_assert=>assert_equals(
      act   = rv_hash
      exp   = 'B751850B1A57168A5693CD924B6B096E08F621827444F70D884F5D0240D2712E10E116E9192AF3C91A7EC57647E3934057340B4CF408D5A56592F8274EEC53F0'
    ).

  endmethod.

  method hash512_empty.

    data(rv_hash) = zcl_sha3=>hash512( iv_message = '' ).

    cl_abap_unit_assert=>assert_equals(
      act   = rv_hash
      exp   = 'A69F73CCA23A9AC5C8B567DC185A756E97C982164FE25859E0D1DCC1475C80A615B2123AF1F5F94C11E3E9402C3AC558F500199D95B6D3E301758586281DCD26'
    ).
  endmethod.

  method hash512_448bits.

    data(rv_hash) = zcl_sha3=>hash512( iv_message = 'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq' ).

    cl_abap_unit_assert=>assert_equals(
      act   = rv_hash
      exp   = '04A371E84ECFB5B8B77CB48610FCA8182DD457CE6F326A0FD3D7EC2F1E91636DEE691FBE0C985302BA1B0D8DC78C086346B533B49C030D99A27DAF1139D6E75E'
    ).
  endmethod.

  method hash512_896bits.

    data(rv_hash) = zcl_sha3=>hash512( iv_message = 'abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu' ).

    cl_abap_unit_assert=>assert_equals(
      act   = rv_hash
      exp   = 'AFEBB2EF542E6579C50CAD06D2E578F9F8DD6881D7DC824D26360FEEBF18A4FA73E3261122948EFCFD492E74E82E2189ED0FB440D187F382270CB455F21DD185'
    ).
  endmethod.

endclass.
