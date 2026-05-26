#include <float.h>
#include <math.h>
#include <stdlib.h>

static const unsigned char ldbl_min[10] = {
    0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x80, 0x01, 0x00,
};

static const unsigned char ldbl_true_min[10] = {
    0x01, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00,
};

static long double static_ldbl_min = LDBL_MIN;
static long double static_ldbl_true_min = LDBL_TRUE_MIN;
static long double static_hex_min = 0x1p-16382L;
static long double static_hex_true_min = 0x1p-16445L;

static int check_bytes(const long double *value, const unsigned char want[10])
{
    const unsigned char *bytes = (const unsigned char *)value;
    int i;

    for (i = 0; i < 10; i++) {
        if (bytes[i] != want[i])
            return 1;
    }
    return 0;
}

static int check_value(long double value, const unsigned char want[10])
{
    return check_bytes(&value, want);
}

int main(void)
{
    int bad = 0;

    bad |= check_bytes(&static_ldbl_min, ldbl_min);
    bad |= check_bytes(&static_ldbl_true_min, ldbl_true_min);
    bad |= check_bytes(&static_hex_min, ldbl_min);
    bad |= check_bytes(&static_hex_true_min, ldbl_true_min);
    bad |= check_value(LDBL_MIN, ldbl_min);
    bad |= check_value(LDBL_TRUE_MIN, ldbl_true_min);
    bad |= check_value(0x1p-16382L, ldbl_min);
    bad |= check_value(0x1p-16445L, ldbl_true_min);
    bad |= check_value(strtold("3.3621031431120935063e-4932", 0), ldbl_min);
    bad |= check_value(strtold("3.6451995318824746025e-4951", 0), ldbl_true_min);
    bad |= check_value(scalbnl(2.0L, -16383), ldbl_min);

    return bad != 0;
}
