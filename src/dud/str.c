#include "str.h"

int dud_strcmp(char *s1, char *s2) {
    int i = 0;

    while (s1[i] == s2[i]) {
        if (s1[i] == '\0') {
            return 0;
        }
        i = i + 1;
    }

    return ((unsigned char) s1[i]) - ((unsigned char) s2[i]);
}

int dud_strlen(char *s) {
    int len = 0;

    while (s[len] != '\0') {
        len = len + 1;
    }

    return len;
}
