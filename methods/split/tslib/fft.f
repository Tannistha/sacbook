c  MULTIVARIATE COMPLEX FOURIER TRANSFORM, COMPUTED IN PLACE
c    USING MIXED-RADIX FAST FOURIER TRANSFORM ALGORITHM.
c  BY R. C. SINGLETON, STANFORD RESEARCH INSTITUTE, SEPT. 1968
c  ARRAYS A AND B ORIGINALLY HOLD THE REAL AND IMAGINARY
c    COMPONENTS OF THE DATA, AND RETURN THE REAL AND
c    IMAGINARY COMPONENTS OF THE RESULTING FOURIER COEFFICIENTS.
c  MULTIVARIATE DATA IS INDEXED ACCORDING TO THE FORTRAN
c    ARRAY ELEMENT SUCCESSOR FUNCTION, WITHOUT LIMIT
c    ON THE NUMBER OF IMPLIED MULTIPLE SUBSCRIPTS.
c    THE SUBROUTINE IS CALLED ONCE FOR EACH VARIATE.
c    THE CALLS FOR A MULTIVARIATE TRANSFORM MAY BE IN ANY ORDER.
c  NTOT IS THE TOTAL NUMBER OF COMPLEX DATA VALUES.
c  N IS THE DIMENSION OF THE CURRENT VARIABLE.
c  NSPAN/N IS THE SPACING OF CONSECUTIVE DATA VALUES
c    WHILE INDEXING THE CURRENT VARIABLE.
c  THE INTEGER IERR IS AN ERROR RETURN INDICATOR. IT IS NORMALLY ZERO, B
cUT IS
c  SET TO 1 IF THE NUMBER OF TERMS CANNOT BE FACTORED IN THE SPACE AVAIL
cABLE. IF
c  IT IS PERMISSIBLE THE APPROPRIATE ACTION AT THIS STAGE IS TO  ENTER F
cFT
c  AGAIN AFTER HAVING REDUCED THE LENGTH OF THE SERIES BY ONE TERM
c  THE SIGN OF ISN DETERMINES THE SIGN OF THE COMPLEX
c    EXPONENTIAL, AND THE MAGNITUDE OF ISN IS NORMALLY ONE.
c  A TRI-VARIATE TRANSFORM WITH A(N1,N2,N3), B(N1,N2,N3)
c    IS COMPUTED BY
c      CALL FFT(A,B,N1*N2*N3,N1,N1,1)
c      CALL FFT(A,B,N1*N2*N3,N2,N1*N2,1)
c      CALL FFT(A,B,N1*N2*N3,N3,N1*N2*N3,1)
c  FOR A SINGLE-VARIATE TRANSFORM,
c    NTOT = N = NSPAN = (NUMBER OF COMPLEX DATA VALUES), E.G.
c      CALL FFT(A,B,N,N,N,1)
c  WITH MOST FORTRAN COMPILERS THE DATA CAN ALTERNATIVELY BE
c    STORED IN A SINGLE COMPLEX ARRAY A, THEN THE MAGNITUDE OF ISN
c    CHANGED TO TWO TO GIVE THE CORRECT INDEXING INCREMENT AND A(2)
c    USED TO PASS THE INITIAL ADDRESS FOR THE SEQUENCE OF IMAGINARY
c    VALUES, E.G.
c      CALL FFT(A,A(2),NTOT,N,NSPAN,2)
c  ARRAYS AT(MAXF), CK(MAXF), BT(MAXF), SK(MAXF), AND NP(MAXP)
c    ARE USED FOR TEMPORARY STORAGE.  IF THE AVAILABLE STORAGE
c    IS INSUFFICIENT, THE PROGRAM IS TERMINATED BY THE ERROR RETURN OPTI
cON
c    MAXF MUST BE .GE. THE MAXIMUM PRIME FACTOR OF N.
c    MAXP MUST BE .GT. THE NUMBER OF PRIME FACTORS OF N.
c    IN ADDITION, IF THE SQUARE-FREE PORTION K OF N HAS TWO OR
c    MORE PRIME FACTORS, THEN MAXP MUST BE .GE. K-1.
      subroutine fft(a, b, ntot, n, nspan, isn, ierr)
c  ARRAY STORAGE IN NFAC FOR A MAXIMUM OF 15 PRIME FACTORS OF N.
c  IF N HAS MORE THAN ONE SQUARE-FREE FACTOR, THE PRODUCT OF THE
c    SQUARE-FREE FACTORS MUST BE .LE. 210
      parameter (maxn=23, maxp=209)
      dimension a(*), b(*)
c  ARRAY STORAGE FOR MAXIMUM PRIME FACTOR OF 23
      dimension nfac(11), np(maxp)
      dimension at(maxn), ck(maxn), bt(maxn), sk(maxn)
c  THE FOLLOWING TWO CONSTANTS SHOULD AGREE WITH THE ARRAY DIMENSIONS.
      equivalence (ii, i)
      maxf = maxn
      ierr = 0
      if (n .lt. 2) return 
      inc = isn
      c72 = 0.30901699437494742
      s72 = 0.95105651629515357
      s120 = 0.86602540378443865
      rad = 6.2831853071796
      if (isn .ge. 0) goto 10
      s72 = - s72
      s120 = - s120
      rad = - rad
      inc = - inc
   10 nt = inc * ntot
      ks = inc * nspan
      kspan = ks
      nn = nt - inc
      jc = ks / n
      radf = (rad * float(jc)) * 0.5
      i = 0
c  DETERMINE THE FACTORS OF N
      jf = 0
      m = 0
      k = n
      goto 20
   15 m = m + 1
      nfac(m) = 4
      k = k / 16
   20 if ((k - ((k / 16) * 16)) .eq. 0) goto 15
      j = 3
      jj = 9
      goto 30
   25 m = m + 1
      nfac(m) = j
      k = k / jj
   30 if (mod(k,jj) .eq. 0) goto 25
      j = j + 2
      jj = j ** 2
      if (jj .le. k) goto 30
      if (k .gt. 4) goto 40
      kt = m
      nfac(m + 1) = k
      if (k .ne. 1) m = m + 1
      goto 80
   40 if ((k - ((k / 4) * 4)) .ne. 0) goto 50
      m = m + 1
      nfac(m) = 2
      k = k / 4
   50 kt = m
      j = 2
   60 if (mod(k,j) .ne. 0) goto 70
      m = m + 1
      nfac(m) = j
      k = k / j
   70 j = (((j + 1) / 2) * 2) + 1
      if (j .le. k) goto 60
   80 if (kt .eq. 0) goto 100
      j = kt
   90 m = m + 1
      nfac(m) = nfac(j)
      j = j - 1
c  COMPUTE FOURIER TRANSFORM
      if (j .ne. 0) goto 90
  100 sd = radf / float(kspan)
      cd = 2.0 * (sin(sd) ** 2)
      sd = sin(sd + sd)
      kk = 1
      i = i + 1
c  TRANSFORM FOR FACTOR OF 2 (INCLUDING ROTATION FACTOR)
      if (nfac(i) .ne. 2) goto 400
      kspan = kspan / 2
      k1 = kspan + 2
  210 k2 = kk + kspan
      ak = a(k2)
      bk = b(k2)
      a(k2) = a(kk) - ak
      b(k2) = b(kk) - bk
      a(kk) = a(kk) + ak
      b(kk) = b(kk) + bk
      kk = k2 + kspan
      if (kk .le. nn) goto 210
      kk = kk - nn
      if (kk .le. jc) goto 210
      if (kk .gt. kspan) goto 800
  220 c1 = 1.0 - cd
      s1 = sd
  230 k2 = kk + kspan
      ak = a(kk) - a(k2)
      bk = b(kk) - b(k2)
      a(kk) = a(kk) + a(k2)
      b(kk) = b(kk) + b(k2)
      a(k2) = (c1 * ak) - (s1 * bk)
      b(k2) = (s1 * ak) + (c1 * bk)
      kk = k2 + kspan
      if (kk .lt. nt) goto 230
      k2 = kk - nt
      c1 = - c1
      kk = k1 - k2
      if (kk .gt. k2) goto 230
      ak = (cd * c1) + (sd * s1)
      s1 = ((sd * c1) - (cd * s1)) + s1
      c1 = c1 - ak
      kk = kk + jc
      if (kk .lt. k2) goto 230
      k1 = (k1 + inc) + inc
      kk = ((k1 - kspan) / 2) + jc
      if (kk .le. (jc + jc)) goto 220
c  TRANSFORM FOR FACTOR OF 3 (OPTIONAL CODE)
      goto 100
  320 k1 = kk + kspan
      k2 = k1 + kspan
      ak = a(kk)
      bk = b(kk)
      aj = a(k1) + a(k2)
      bj = b(k1) + b(k2)
      a(kk) = ak + aj
      b(kk) = bk + bj
      ak = (- (0.5 * aj)) + ak
      bk = (- (0.5 * bj)) + bk
      aj = (a(k1) - a(k2)) * s120
      bj = (b(k1) - b(k2)) * s120
      a(k1) = ak - bj
      b(k1) = bk + aj
      a(k2) = ak + bj
      b(k2) = bk - aj
      kk = k2 + kspan
      if (kk .lt. nn) goto 320
      kk = kk - nn
      if (kk .le. kspan) goto 320
c  TRANSFORM FOR FACTOR OF 4
      goto 700
  400 if (nfac(i) .ne. 4) goto 600
      kspnn = kspan
      kspan = kspan / 4
  410 c1 = 1.0
      s1 = 0
  420 k1 = kk + kspan
      k2 = k1 + kspan
      k3 = k2 + kspan
      akp = a(kk) + a(k2)
      akm = a(kk) - a(k2)
      ajp = a(k1) + a(k3)
      ajm = a(k1) - a(k3)
      a(kk) = akp + ajp
      ajp = akp - ajp
      bkp = b(kk) + b(k2)
      bkm = b(kk) - b(k2)
      bjp = b(k1) + b(k3)
      bjm = b(k1) - b(k3)
      b(kk) = bkp + bjp
      bjp = bkp - bjp
      if (isn .lt. 0) goto 450
      akp = akm - bjm
      akm = akm + bjm
      bkp = bkm + ajm
      bkm = bkm - ajm
      if (s1 .eq. 0) goto 460
  430 a(k1) = (akp * c1) - (bkp * s1)
      b(k1) = (akp * s1) + (bkp * c1)
      a(k2) = (ajp * c2) - (bjp * s2)
      b(k2) = (ajp * s2) + (bjp * c2)
      a(k3) = (akm * c3) - (bkm * s3)
      b(k3) = (akm * s3) + (bkm * c3)
      kk = k3 + kspan
      if (kk .le. nt) goto 420
  440 c2 = (cd * c1) + (sd * s1)
      s1 = ((sd * c1) - (cd * s1)) + s1
      c1 = c1 - c2
      c2 = (c1 ** 2) - (s1 ** 2)
      s2 = (2.0 * c1) * s1
      c3 = (c2 * c1) - (s2 * s1)
      s3 = (c2 * s1) + (s2 * c1)
      kk = (kk - nt) + jc
      if (kk .le. kspan) goto 420
      kk = (kk - kspan) + inc
      if (kk .le. jc) goto 410
      if (kspan .eq. jc) goto 800
      goto 100
  450 akp = akm + bjm
      akm = akm - bjm
      bkp = bkm - ajm
      bkm = bkm + ajm
      if (s1 .ne. 0) goto 430
  460 a(k1) = akp
      b(k1) = bkp
      a(k2) = ajp
      b(k2) = bjp
      a(k3) = akm
      b(k3) = bkm
      kk = k3 + kspan
      if (kk .le. nt) goto 420
c  TRANSFORM FOR FACTOR OF 5 (OPTIONAL CODE)
      goto 440
  510 c2 = (c72 ** 2) - (s72 ** 2)
      s2 = (2.0 * c72) * s72
  520 k1 = kk + kspan
      k2 = k1 + kspan
      k3 = k2 + kspan
      k4 = k3 + kspan
      akp = a(k1) + a(k4)
      akm = a(k1) - a(k4)
      bkp = b(k1) + b(k4)
      bkm = b(k1) - b(k4)
      ajp = a(k2) + a(k3)
      ajm = a(k2) - a(k3)
      bjp = b(k2) + b(k3)
      bjm = b(k2) - b(k3)
      aa = a(kk)
      bb = b(kk)
      a(kk) = (aa + akp) + ajp
      b(kk) = (bb + bkp) + bjp
      ak = ((akp * c72) + (ajp * c2)) + aa
      bk = ((bkp * c72) + (bjp * c2)) + bb
      aj = (akm * s72) + (ajm * s2)
      bj = (bkm * s72) + (bjm * s2)
      a(k1) = ak - bj
      a(k4) = ak + bj
      b(k1) = bk + aj
      b(k4) = bk - aj
      ak = ((akp * c2) + (ajp * c72)) + aa
      bk = ((bkp * c2) + (bjp * c72)) + bb
      aj = (akm * s2) - (ajm * s72)
      bj = (bkm * s2) - (bjm * s72)
      a(k2) = ak - bj
      a(k3) = ak + bj
      b(k2) = bk + aj
      b(k3) = bk - aj
      kk = k4 + kspan
      if (kk .lt. nn) goto 520
      kk = kk - nn
      if (kk .le. kspan) goto 520
c  TRANSFORM FOR ODD FACTORS
      goto 700
  600 k = nfac(i)
      kspnn = kspan
      kspan = kspan / k
      if (k .eq. 3) goto 320
      if (k .eq. 5) goto 510
      if (k .eq. jf) goto 640
      jf = k
      s1 = rad / float(k)
      c1 = cos(s1)
      s1 = sin(s1)
      if (jf .gt. maxf) goto 998
      ck(jf) = 1.0
      sk(jf) = 0.0
      j = 1
  630 ck(j) = (ck(k) * c1) + (sk(k) * s1)
      sk(j) = (ck(k) * s1) - (sk(k) * c1)
      k = k - 1
      ck(k) = ck(j)
      sk(k) = - sk(j)
      j = j + 1
      if (j .lt. k) goto 630
  640 k1 = kk
      k2 = kk + kspnn
      aa = a(kk)
      bb = b(kk)
      ak = aa
      bk = bb
      j = 1
      k1 = k1 + kspan
  650 k2 = k2 - kspan
      j = j + 1
      at(j) = a(k1) + a(k2)
      ak = at(j) + ak
      bt(j) = b(k1) + b(k2)
      bk = bt(j) + bk
      j = j + 1
      at(j) = a(k1) - a(k2)
      bt(j) = b(k1) - b(k2)
      k1 = k1 + kspan
      if (k1 .lt. k2) goto 650
      a(kk) = ak
      b(kk) = bk
      k1 = kk
      k2 = kk + kspnn
      j = 1
  660 k1 = k1 + kspan
      k2 = k2 - kspan
      jj = j
      ak = aa
      bk = bb
      aj = 0.0
      bj = 0.0
      k = 1
  670 k = k + 1
      ak = (at(k) * ck(jj)) + ak
      bk = (bt(k) * ck(jj)) + bk
      k = k + 1
      aj = (at(k) * sk(jj)) + aj
      bj = (bt(k) * sk(jj)) + bj
      jj = jj + j
      if (jj .gt. jf) jj = jj - jf
      if (k .lt. jf) goto 670
      k = jf - j
      a(k1) = ak - bj
      b(k1) = bk + aj
      a(k2) = ak + bj
      b(k2) = bk - aj
      j = j + 1
      if (j .lt. k) goto 660
      kk = kk + kspnn
      if (kk .le. nn) goto 640
      kk = kk - nn
c  MULTIPLY BY ROTATION FACTOR (EXCEPT FOR FACTORS OF 2 AND 4)
      if (kk .le. kspan) goto 640
  700 if (i .eq. m) goto 800
      kk = jc + 1
  710 c2 = 1.0 - cd
      s1 = sd
  720 c1 = c2
      s2 = s1
      kk = kk + kspan
  730 ak = a(kk)
      a(kk) = (c2 * ak) - (s2 * b(kk))
      b(kk) = (s2 * ak) + (c2 * b(kk))
      kk = kk + kspnn
      if (kk .le. nt) goto 730
      ak = s1 * s2
      s2 = (s1 * c2) + (c1 * s2)
      c2 = (c1 * c2) - ak
      kk = (kk - nt) + kspan
      if (kk .le. kspnn) goto 730
      c2 = c1 - ((cd * c1) + (sd * s1))
      s1 = s1 + ((sd * c1) - (cd * s1))
      kk = (kk - kspnn) + jc
      if (kk .le. kspan) goto 720
      kk = ((kk - kspan) + jc) + inc
      if (kk .le. (jc + jc)) goto 710
c  PERMUTE THE RESULTS TO NORMAL ORDER---DONE IN TWO STAGES
c  PERMUTATION FOR SQUARE FACTORS OF N
      goto 100
  800 np(1) = ks
      if (kt .eq. 0) goto 890
      k = (kt + kt) + 1
      if (m .lt. k) k = k - 1
      j = 1
      np(k + 1) = jc
  810 np(j + 1) = np(j) / nfac(j)
      np(k) = np(k + 1) * nfac(j)
      j = j + 1
      k = k - 1
      if (j .lt. k) goto 810
      k3 = np(k + 1)
      kspan = np(2)
      kk = jc + 1
      k2 = kspan + 1
      j = 1
c  PERMUTATION FOR SINGLE-VARIATE TRANSFORM (OPTIONAL CODE)
      if (n .ne. ntot) goto 850
  820 ak = a(kk)
      a(kk) = a(k2)
      a(k2) = ak
      bk = b(kk)
      b(kk) = b(k2)
      b(k2) = bk
      kk = kk + inc
      k2 = kspan + k2
      if (k2 .lt. ks) goto 820
  830 k2 = k2 - np(j)
      j = j + 1
      k2 = np(j + 1) + k2
      if (k2 .gt. np(j)) goto 830
      j = 1
  840 if (kk .lt. k2) goto 820
      kk = kk + inc
      k2 = kspan + k2
      if (k2 .lt. ks) goto 840
      if (kk .lt. ks) goto 830
      jc = k3
c  PERMUTATION FOR MULTIVARIATE TRANSFORM
      goto 890
  850 k = kk + jc
  860 ak = a(kk)
      a(kk) = a(k2)
      a(k2) = ak
      bk = b(kk)
      b(kk) = b(k2)
      b(k2) = bk
      kk = kk + inc
      k2 = k2 + inc
      if (kk .lt. k) goto 860
      kk = (kk + ks) - jc
      k2 = (k2 + ks) - jc
      if (kk .lt. nt) goto 850
      k2 = (k2 - nt) + kspan
      kk = (kk - nt) + jc
      if (k2 .lt. ks) goto 850
  870 k2 = k2 - np(j)
      j = j + 1
      k2 = np(j + 1) + k2
      if (k2 .gt. np(j)) goto 870
      j = 1
  880 if (kk .lt. k2) goto 850
      kk = kk + jc
      k2 = kspan + k2
      if (k2 .lt. ks) goto 880
      if (kk .lt. ks) goto 870
      jc = k3
  890 if (((2 * kt) + 1) .ge. m) return 
c  PERMUTATION FOR SQUARE-FREE FACTORS OF N
      kspnn = np(kt + 1)
      j = m - kt
      nfac(j + 1) = 1
  900 nfac(j) = nfac(j) * nfac(j + 1)
      j = j - 1
      if (j .ne. kt) goto 900
      kt = kt + 1
      nn = nfac(kt) - 1
      if (nn .gt. maxp) goto 998
      jj = 0
      j = 0
      goto 906
  902 jj = jj - k2
      k2 = kk
      k = k + 1
      kk = nfac(k)
  904 jj = kk + jj
      if (jj .ge. k2) goto 902
      np(j) = jj
  906 k2 = nfac(kt)
      k = kt + 1
      kk = nfac(k)
      j = j + 1
c  DETERMINE THE PERMUTATION CYCLES OF LENGTH GREATER THAN 1
      if (j .le. nn) goto 904
      j = 0
      goto 914
  910 k = kk
      kk = np(k)
      np(k) = - kk
      if (kk .ne. j) goto 910
      k3 = kk
  914 j = j + 1
      kk = np(j)
      if (kk .lt. 0) goto 914
      if (kk .ne. j) goto 910
      np(j) = - j
      if (j .ne. nn) goto 914
c  REORDER A AND B, FOLLOWING THE PERMUTATION CYCLES
      maxf = inc * maxf
      goto 950
  924 j = j - 1
      if (np(j) .lt. 0) goto 924
      jj = jc
  926 kspan = jj
      if (jj .gt. maxf) kspan = maxf
      jj = jj - kspan
      k = np(j)
      kk = ((jc * k) + ii) + jj
      k1 = kk + kspan
      k2 = 0
  928 k2 = k2 + 1
      at(k2) = a(k1)
      bt(k2) = b(k1)
      k1 = k1 - inc
      if (k1 .ne. kk) goto 928
  932 k1 = kk + kspan
      k2 = k1 - (jc * (k + np(k)))
      k = - np(k)
  936 a(k1) = a(k2)
      b(k1) = b(k2)
      k1 = k1 - inc
      k2 = k2 - inc
      if (k1 .ne. kk) goto 936
      kk = k2
      if (k .ne. j) goto 932
      k1 = kk + kspan
      k2 = 0
  940 k2 = k2 + 1
      a(k1) = at(k2)
      b(k1) = bt(k2)
      k1 = k1 - inc
      if (k1 .ne. kk) goto 940
      if (jj .ne. 0) goto 926
      if (j .ne. 1) goto 924
  950 j = k3 + 1
      nt = nt - kspnn
      ii = (nt - inc) + 1
      if (nt .ge. 0) goto 924
c  ERROR FINISH, INSUFFICIENT ARRAY STORAGE
      return 
  998 write(unit=*, fmt=999) 
      ierr = 1
  999 format(44h0ARRAY BOUNDS EXCEEDED WITHIN SUBROUTINE FFT)
      end
