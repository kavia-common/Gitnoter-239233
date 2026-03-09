#ifndef IMPORTNOTEDIALOG_H
#define IMPORTNOTEDIALOG_H

#include "notemodel.h"

#include <QDialog>

#ifdef QT_XMLPATTERNS_LIB
#include <QXmlQuery>
#include <QXmlResultItems>
#endif

namespace Ui {
class ImportNoteDialog;
}

class ImportNoteDialog : public QDialog
{
    Q_OBJECT

public:
    struct MediaFileData {
        QString data;
        QString suffix;
        QString fileName;
    };

    explicit ImportNoteDialog(QWidget *parent = 0);
    ~ImportNoteDialog();

    void init();

protected:
    void showEvent(QShowEvent *showEvent) override;

private:
    void initProgressBar(QString data);
    void importNotes(QString data);

#ifdef QT_XMLPATTERNS_LIB
    QString importImages(NoteModel *noteModel, QString content, QXmlQuery query);
    QString importAttachments(NoteModel *noteModel, QString content, QXmlQuery query);
#endif

    QString getMarkdownForMediaFileData(NoteModel *noteModel, MediaFileData &mediaFileData);
    QString getMarkdownForAttachmentFileData(NoteModel *noteModel, MediaFileData &mediaFileData);

    QString decodeHtmlEntities(QString text);

private:
    Ui::ImportNoteDialog *ui;

};

#endif // IMPORTNOTEDIALOG_H
