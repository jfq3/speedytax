test_that("Can parse qiime2 classification file", {

  #x = "abfbb47b2ad04a353709c425f1c8466f        d__Eukaryota;p__Ascomycota;c__Dothideomycetes;o__Pleosporales;f__;g__   0.8476371480572471"
  x = "classification-test-file.tsv"

  expected = 'abfbb47b2ad04a353709c425f1c8466f "d_Eukaryota" "p_Ascomycota" "c__Dothideomycetes" "o__Pleosporales" "o__Pleosporales" "o__Pleosporales"'

  rslt <- import_qiime2_tax_table(x)

  expect_equal(rslt, expected)
})
